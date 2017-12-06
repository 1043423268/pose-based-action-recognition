#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <string.h>
#include <vector>
#include <cmath>
#include <cstdlib>
#include <climits>
using namespace std;

int main(int argc, char *argv[])
{

    //function：将训练集或测试集样本的fv特征及对应标签写入一个txt，生成liblinear库要求的格式。
    //../split1/trainset_label_split1.txt ../split1/trainset_split1.txt l2_total ../split1/randw_trainset_svm_split1.txt
    if (argc < 5)   {
        cout<<"Usage: "<<argv[0]<<"labellist fvlist fvtype outputdata"<<endl;
        return 0;
    }
    string labellist(argv[1]);
    string fvlist(argv[2]);
    string fvtype(argv[3]);
    string outputdata(argv[4]);


    ifstream fin1,fin2;
    fin1.open(labellist.c_str());
    if (!fin1.is_open())    {
        cout<<"Cannot open "<<labellist<<endl;
        return 0;
    }
    fin2.open(fvlist.c_str());
    if (!fin1.is_open())    {
        cout<<"Cannot open "<<fvlist<<endl;
        return 0;
    }

    ofstream fout;
    fout.open(outputdata.c_str());

    string line,fvline;
    string labelline;
    int label,index;

    while(getline(fin2,line)){//获取fv特征路径
        if(line=="")
            break;
        index=1;

        getline(fin1,labelline);
        label=atoi(labelline.c_str());
        fout<<label;

        ifstream fin;
        fvline=line+"/"+fvtype+".txt";
        fin.open(fvline.c_str());
        if (!fin.is_open())    {
            cout<<"Cannot open "<<fvline<<endl;
            return 0;
        }
        string value;
        while(fin>>value){

            fout<<"\t"<<index++<<":"<<value;
        }
        fout<<"\n";
    }
    fin1.close();fin2.close();fout.close();
    return 0;

}
