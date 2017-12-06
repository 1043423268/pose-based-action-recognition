#include "fisher.h"

FisherVector::FisherVector(string codeBookFile, bool whitening)   {

    codeBook = new GMMWrapper(codeBookFile);

    numSP = 1;              // default: 1 layer of spatial pyramid
    startFrame = 0;         // default: whole video
    endFrame = INT_MAX;
    numPts = 0;
    // precompute sqrt inv of cov mat
    sqrtInvSigma = new double[codeBook->numClusters*codeBook->dimension];
    for (int cluster = 0; cluster < codeBook->numClusters; cluster++)
        for (int dim = 0; dim < codeBook->dimension; dim++)
            sqrtInvSigma[cluster*codeBook->dimension + dim] = sqrt(1.0 / codeBook->covs[cluster*codeBook->dimension + dim]);
}

FisherVector::~FisherVector()   {

    if (codeBook)
        delete codeBook;
    if (sqrtInvSigma)
        delete [] sqrtInvSigma;
}

bool FisherVector::initFV(int numSP, int startFrame, int endFrame)  {
    if (numSP < 1 || numSP > 3) {
        cout<<"Invalid number of spatial pyramid layers."<<endl;
        return false;
    }
    if (startFrame < 0 || startFrame > endFrame)    {
        cout<<"Invalid range of frames."<<endl;
        return false;
    }
    this->numSP = numSP;
    this->startFrame = startFrame;
    this->endFrame = endFrame;
    numPts = 0;

    // allocate space
    int dimPerPyr = codeBook->dimension * codeBook->numClusters * 2;        // 2KD
    int numPyr = (pow(4, numSP)-1)/3;

    if (fv.size() > 0)
        fv.clear();
    fv.resize(dimPerPyr * numPyr, 0.0);
    return true;
}

bool FisherVector::addPoint(vector<double> feat)   {


    // local fv before added to sp fv
    vector<double> lfv(codeBook->dimension * codeBook->numClusters * 2, 0.0);
    // compute soft-assignments with gmm
    double *posteriors = new double[codeBook->numClusters];
    vl_get_gmm_data_posteriors_d(posteriors, codeBook->numClusters, 1, codeBook->priors, codeBook->means, codeBook->dimension, codeBook->covs, (double *)&feat[0]);
    // compute fv
    for (int cluster = 0; cluster < codeBook->numClusters; cluster++)   {
        int ptr1 = cluster * codeBook->dimension;       // for first-order term
        int ptr2 = cluster * codeBook->dimension + codeBook->dimension * codeBook->numClusters;     // for second-order term
        double posterior = posteriors[cluster];
        for (int dim = 0; dim < codeBook->dimension; dim++) {
            double diff = feat[dim] - codeBook->means[cluster*codeBook->dimension + dim];
            diff *= sqrtInvSigma[cluster*codeBook->dimension + dim];
            lfv[ptr1+dim] += posterior * diff;
            lfv[ptr2+dim] += posterior * (diff * diff - 1);
        }
    }
    delete [] posteriors;
    // add to corresponding spatial blocks
    for (int layer = 0; layer < numSP; layer++) {

        for (int dim = 0; dim < lfv.size(); dim++)
          fv[dim] += lfv[dim];
    }
    numPts++;
    return true;
}

vector<double> &FisherVector::getFV()   {
    if (numPts < 1)
        return fv;
    // normalize by sqrt and l2 for each component separately
    for (int pry = 0; pry < (pow(4, numSP)-1)/3; pry++) {       // enumerate
        int ptr = codeBook->dimension * codeBook->numClusters * 2 * pry;
        double fv1_sum = 0.0;
        double fv2_sum = 0.0;
        for (int cluster = 0; cluster < codeBook->numClusters; cluster++)   {
            double prefix1 = 1/(numPts*sqrt(codeBook->priors[cluster]));
            double prefix2= 1/(numPts*sqrt(2.0*codeBook->priors[cluster]));
            for (int dim = 0; dim < codeBook->dimension; dim++) {
                // fill the missing fv terms
                fv[ptr+cluster*codeBook->dimension+dim] *= prefix1;
                fv[ptr+codeBook->dimension*codeBook->numClusters + cluster*codeBook->dimension+dim] *= prefix2;
                // sqrt norm
                if (fv[ptr+cluster*codeBook->dimension+dim] > 0)
                    fv[ptr+cluster*codeBook->dimension+dim] = sqrt(fv[ptr+cluster*codeBook->dimension+dim]);
                else
                    fv[ptr+cluster*codeBook->dimension+dim] = -sqrt(-fv[ptr+cluster*codeBook->dimension+dim]);

                if (fv[ptr+codeBook->dimension*codeBook->numClusters + cluster*codeBook->dimension+dim] > 0)
                    fv[ptr+codeBook->dimension*codeBook->numClusters + cluster*codeBook->dimension+dim] = sqrt(fv[ptr+codeBook->dimension*codeBook->numClusters + cluster*codeBook->dimension+dim]);
                else
                    fv[ptr+codeBook->dimension*codeBook->numClusters + cluster*codeBook->dimension+dim] = -sqrt(-fv[ptr+codeBook->dimension*codeBook->numClusters + cluster*codeBook->dimension+dim]);
            }
        }
        // l2 norm
        for (int dim = 0; dim < codeBook->dimension * codeBook->numClusters; dim++) {
            fv1_sum += fv[ptr+dim] * fv[ptr+dim];
            fv2_sum += fv[ptr+codeBook->dimension * codeBook->numClusters+dim] * fv[ptr+codeBook->dimension * codeBook->numClusters+dim];
        }
        fv1_sum = sqrt(fv1_sum);
        fv2_sum = sqrt(fv2_sum);
        if (fv1_sum > 1e-10 && fv2_sum > 1e-10) {
            for (int dim = 0; dim < codeBook->dimension * codeBook->numClusters; dim++) {
                fv[ptr+dim] /= fv1_sum;
                fv[ptr+codeBook->dimension * codeBook->numClusters+dim] /= fv2_sum;
            }
        }
    }
    return fv;
}

bool FisherVector::clearFV()    {
    numSP = 1;
    startFrame = 0;
    endFrame = INT_MAX;
    fv.clear();
    numPts = 0;
    return true;
}

