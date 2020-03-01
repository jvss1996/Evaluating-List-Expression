#include <iostream>
#include <stdio.h>
#include <fstream>

using namespace std;

extern FILE* yyin;
extern int yylex();

int main(int argc, char **argv)
{
  if (argc == 2)
  {
    string filename = argv[1];
    string file1 = filename.substr(filename.find("=")+1, filename.length());
    string file_nam, file_nam1;
    for(int u=0; u<file1.length(); u++)
    {
      if(file1[u]!='.')
      {
        file_nam1 = file_nam1 + file1[u];
      }
      else{break;}
    }
    const char *cha = file1.c_str();
    if(FILE *file = fopen(cha, "r"))
    {
      yyin = fopen(cha, "r");
      yylex();
    }
    else
    {
      cout << "File doesn't exists" << endl;
      return false;
    }
    return 0;
  }
}
