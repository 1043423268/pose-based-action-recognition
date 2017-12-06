#include "fisher.h"
#include "feature.h"

#include <vector>
#include <string>
#include <iostream>
using namespace std;
int compt_fv(string inputfeatures,string codebookfile,string outputbase,string featuretype);
int combinefv(string inputfeatpathlist,string featuretype[],string outtype);
/*
 * A sample use of fisher vector coding with DT.
 * Require 5 PCA projection matrices and 5 GMM codebooks
 * for each component of DT: TRAJ, HOG, HOF, MBHX, MBHY
 * Read input from stdin
 */


int main(int argc, char **argv){
    //function：利用coodbook计算所有样本的FV特征:2KD维特征
    if (argc < 3)   {
        cout<<"Usage: "<<argv[0]<<" inputfeatpathlist codebookpath"<<endl;
        // ../inputfeaturelist.txt  ../hlpf_codebook/
        return 0;
    }
    // Important: GMM uses OpenMP to speed up
    // This will cause problem on cluster where all
    // cores from a node run this binary
    //vl_set_num_threads(1);

    string inputfeatpathlist(argv[1]);
    string codebookpath(argv[2]);

    string featuretype[9]={"norm_positions","dist_relations","ort_relations", "angle_relations",
                            "cartesian_trajectory","radial_trajectory","dist_relation_trajectory",
                           "ort_relation_trajectory","angle_relation_trajectory"};

    ifstream fin;
    fin.open(inputfeatpathlist.c_str());
    if (!fin.is_open())    {
        cout<<"Cannot open "<<inputfeatpathlist<<endl;
        return 0;
    }
    string line;
    string codebookfile;
    string inputfeatlist;
    string outputbase;



    while (getline(fin, line))  {

        for(int i=0;i<9;i++){

            codebookfile=codebookpath+"codebook_"+featuretype[i]+".txt";
            inputfeatlist=line+"/"+featuretype[i]+".txt";
            outputbase=line+"/";

            compt_fv(inputfeatlist,codebookfile,outputbase,featuretype[i]);
        }
    }
    fin.close();

    combinefv(inputfeatpathlist,featuretype,"s1_total");

    return 0;

}



int compt_fv(string inputfeatures,string codebookfile,string outputbase,string featuretype){

    vector<FisherVector*> fvs(1, NULL);

    for (int i = 0; i < fvs.size(); i++)    {
 //     getline(fin2, codeBookFile);
        fvs[i] = new FisherVector(codebookfile);
        fvs[i]->initFV(1);  // 1 layer of spatial pyramids
    }

    ifstream fin;
    fin.open(inputfeatures.c_str());
    if (!fin.is_open())    {
        cout<<"Cannot open "<<inputfeatures<<endl;
        return 0;
    }
    string line;
    while (getline(fin, line))  {

        double val;
        stringstream ss(line);
        vector<double> features;
        while (ss>>val)
            features.push_back(val);
        fvs[0]->addPoint(features);

    }
    fin.close();
    cout<<"Points load complete."<<endl;
    for (int i = 0; i < fvs.size(); i++)    {
        ofstream fout;
        string outName = outputbase + featuretype + "_fv.txt";
        fout.open(outName.c_str());
        vector<double> fv = fvs[i]->getFV();
        fout<<fv[0];
        for (int j = 1; j < fv.size(); j++)
            fout<<" "<<fv[j];
        fout<<endl;
        fout.close();
        fvs[i]->clearFV();
    }

    for (int i = 0; i < fvs.size(); i++)
        delete fvs[i];

    return 0;
}


int combinefv(string inputfeatpathlist,string featuretype[],string outtype)//将9种原始未加权的fv特征串联
{
    ifstream fin;
    fin.open(inputfeatpathlist.c_str());
    if (!fin.is_open())    {
        cout<<"Cannot open "<<inputfeatpathlist<<endl;
        return 0;
    }
    string line;

    string inputfvpath;

    while (getline(fin, line))  {

        vector<double> inputfvdata;
        for(int i=0;i<9 ;i++){

            inputfvpath=line+"/"+featuretype[i]+"_fv.txt";//将9种类型的fv特征串联

            ifstream fvfin;
            fvfin.open(inputfvpath.c_str());
            if (!fvfin.is_open())    {
                cout<<"Cannot open "<<inputfvpath<<endl;
                return 0;
            }
            string line;
            while (getline(fvfin, line))  {

                double val;
                stringstream ss(line);
                while (ss>>val)
                    inputfvdata.push_back(val);
            }
            fvfin.close();

        }

        ofstream fout;
        string outName = line + "/"+outtype+"_fv.txt";//串联后写入该路径下的total_fv.txt中
        fout.open(outName.c_str());
        fout<<inputfvdata[0];
        for (int j = 1; j < inputfvdata.size(); j++)
            fout<<" "<<inputfvdata[j];
        fout<<endl;
        fout.close();

        inputfvdata.swap(inputfvdata);

    }
    fin.close();

    return 0;
}

