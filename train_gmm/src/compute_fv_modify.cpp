#include "fisher.h"
#include "feature.h"

/*
 * A sample use of fisher vector coding with DT.
 * Require 5 PCA projection matrices and 5 GMM codebooks 
 * for each component of DT: TRAJ, HOG, HOF, MBHX, MBHY
 * Read input from stdin
 */

int main(int argc, char **argv) {
    if (argc < 4)   {
        cout<<"Usage: "<<argv[0]<<"pcaList codeBookList outputBase"<<endl;
        return 0;
    }
    // Important: GMM uses OpenMP to speed up
    // This will cause problem on cluster where all cores from a node run this binary
    vl_set_num_threads(1);
    string pcaList(argv[1]);
    string codeBookList(argv[2]);
    string outputBase(argv[3]);
    string types[5] = {"traj", "hog", "hof", "mbhx", "mbhy"};
    vector<FisherVector*> fvs(5, NULL);

    ifstream fin1, fin2;
    fin1.open(pcaList.c_str());
    if (!fin1.is_open())    {
        cout<<"Cannot open "<<pcaList<<endl;
        return 0;
    }
    fin2.open(codeBookList.c_str());
    if (!fin2.is_open())    {
        cout<<"Cannot open "<<codeBookList<<endl;
        return 0;
    }

    ifstream fin;
    fin.open("output.features");
    if (!fin.is_open())    {
        cout<<"Cannot open "<<"output.features"<<endl;
        return 0;
    }

    string pcaFile, codeBookFile;
    for (int i = 0; i < fvs.size(); i++)    {
        getline(fin1, pcaFile);
        getline(fin2, codeBookFile);
        fvs[i] = new FisherVector(pcaFile, codeBookFile);
        fvs[i]->initFV(1);  // 1 layer of spatial pyramids
    }
    fin1.close();
    fin2.close();

    string line;
    while (getline(fin, line))  {
        DTFeature feat(line);
        //TODO: Store feature of DT with vector<double>
        vector<double> traj(feat.traj, feat.traj+TRAJ_DIM);
        vector<double> hog(feat.hog, feat.hog+HOG_DIM);
        vector<double> hof(feat.hof, feat.hof+HOF_DIM);
        vector<double> mbhx(feat.mbhx, feat.mbhx+MBHX_DIM);
        vector<double> mbhy(feat.mbhy, feat.mbhy+MBHY_DIM);
        fvs[0]->addPoint(traj, feat.x_pos, feat.y_pos);
        fvs[1]->addPoint(hog, feat.x_pos, feat.y_pos);
        fvs[2]->addPoint(hof, feat.x_pos, feat.y_pos);
        fvs[3]->addPoint(mbhx, feat.x_pos, feat.y_pos);
        fvs[4]->addPoint(mbhy, feat.x_pos, feat.y_pos);
    }
    cout<<"Points load complete."<<endl;


    vector<double> fv0,fv1,fv2,fv3,fv4;
    fv0 = fvs[0]->getFV();
    fv1 = fvs[1]->getFV();
    fv2 = fvs[2]->getFV();
    fv3 = fvs[3]->getFV();
    fv4 = fvs[4]->getFV();
    vector<double> fv_[5]={fv0,fv1,fv2,fv3,fv4};

    for (int i = 0; i < fvs.size(); i++)    {
        ofstream fout;
        string outName = outputBase + types[i] + ".fv.txt";
        fout.open(outName.c_str());
        vector<double> fv = fvs[i]->getFV();
        fout<<fv[0];
        for (int j = 1; j < fv.size(); j++)
            fout<<" "<<fv[j];
        fout<<endl;
        fout.close();
        fvs[i]->clearFV();
    }


    ofstream fout_;
    string outName_ =  outputBase + "fv.txt";
    fout_.open(outName_.c_str());
    fout_<<fv0[0];
    for (int j = 1; j < fv0.size(); j++)
        fout_<<" "<<fv0[j];

    for (int j = 0; j < fv1.size(); j++)
        fout_<<" "<<fv1[j];

    for (int j = 0; j < fv2.size(); j++)
        fout_<<" "<<fv2[j];

    for (int j = 0; j < fv3.size(); j++)
        fout_<<" "<<fv3[j];

    for (int j = 0; j < fv4.size(); j++)
        fout_<<" "<<fv4[j];
    fout_<<endl;
    fout_.close();

    ofstream fout1_;
    string outName1_ =  outputBase + "mbh.fv.txt";
    fout1_.open(outName1_.c_str());
    fout1_<<fv3[0];
    for (int j = 1; j < fv3.size(); j++)
        fout1_<<" "<<fv3[j];
    for (int j = 0; j < fv4.size(); j++)
        fout1_<<" "<<fv4[j];

    fout1_<<endl;
    fout1_.close();



    for (int i = 0; i < fvs.size(); i++)
        delete fvs[i];
    return 0;
}
