%option noyywrap
%{
  #include<iostream>
  #include<map>
  #include<string>
  #include<algorithm>
  #include<vector>
  #include<ctype.h>
  #include<fstream>
  #include <list>
  #include<iterator>
  #include<sstream>
  using namespace std;
  ofstream pyfile;
  map<string, string> map1;
  vector<string> split(const string& str, const string& delim)
  {
  	vector<string> tokens;
  	size_t prev = 0, pos = 0;
  	do
  	{
  		pos = str.find(delim, prev);
  		if (pos == string::npos) pos = str.length();
  		string token = str.substr(prev, pos - prev);
  		if (!token.empty()) tokens.push_back(token);
  		prev = pos + delim.length();
  	} while (pos < str.length() && prev < str.length());
	return tokens;
  }
  string removeSpaces(string str)
  {
    str.erase(remove(str.begin(), str.end(), ' '), str.end());
    return str;
  }
  void print_msg(std::map<string, string> map_result)
  {
    if(pyfile.is_open())
    {
      map<string, string>::iterator itr;
      for (itr = map_result.begin(); itr != map_result.end(); ++itr) {
            pyfile << ">>>" << itr->second << "\n";
      }
    }
    else
    {
      pyfile.open("output.out");
      map<string, string>::iterator itr;
      for (itr = map_result.begin(); itr != map_result.end(); ++itr) {
            pyfile << ">>>" << itr->second << "\n";
      }
    }
  }
  void print_line(string str)
  {
    if(pyfile.is_open())
    {
      pyfile << str << "\n";
    }
    else
    {
      pyfile.open("output.out");
      pyfile << "##### tc.py #####" << "\n";
      pyfile << str << "\n";
    }
  }
  string after_occ(string str, char ch, int count)
  {
    int occ = 0, i;
    for (i = 0; i < str.length(); i++) {
        if (str[i] == ch)
            occ++;
        if (occ == count)
            break;
    }
    if (i < str.length() - 1)
        return str.substr(i + 1, str.length() - (i + 1));
    else
        return "";
  }
  string count_after(string str, char chr)
  {
    string value= "";
    for(int i = 0; i < str.length(); i++){
      if(str[i] != chr){
          value += str[i];
      }
      else{
        break;
      }
    }
    return value;
  }

%}

IDENT     [a-zA-Z][a-zA-Z0-9]*
DIGIT     [0-9][0-9]*
ASSIGN    ["="]
PLUS      ["+"]
SYMB      ([">"]|["<"]|["="]*)
IFELSE    {IDENT}{ASSIGN}({DIGIT}|["\""]*{IDENT}["\""]*)([" "]*if[" "]*{IDENT}{SYMB}({DIGIT}|{IDENT})[" "]*else[" "]*((["\-"]*{DIGIT})|(["\""]*{IDENT}["\""]*)))*
NEWVAR    {IDENT}[" "]*{ASSIGN}[" "]*((["\["]["\'"]*["\""]*({IDENT}|{DIGIT})["\""]*["\'"]*["\]"])|["\'"]{IDENT}["\'"])
ADD       ((["("]*["\["]*({IDENT}|{DIGIT})["\]"]*[")"]*)|(["\["]({DIGIT}|(["\'"]{IDENT}["\'"])|{IDENT})["\]"]))
CONCAT    {IDENT}[" "]*{ASSIGN}[" "]*{ADD}([" "]*{PLUS}[" "]*{ADD})+
PRINT     print["("]{IDENT}(["\["]{DIGIT}[":"]*["\]"])*[")"]

%%

{NEWVAR}    {
  string assign_r = "";
  string assign_r_1 = "";
  string temp1 = "";
  string assign_l = "";
  for(int j=0; j<yyleng; j++)
  {
    temp1 = temp1 + yytext[j];
  }
  for(int i = 0; i < yyleng; i++){
    if(yytext[i] != '='){
        assign_l = assign_l + yytext[i];
    }
    else{
      break;
    }
  }
  //cout << temp1;
  assign_l = removeSpaces(assign_l);
  assign_r = temp1.substr(temp1.find("=") + 1, temp1.length());
  assign_r = removeSpaces(assign_r);
  assign_r = assign_r.substr(assign_r.find("[")+1, assign_r.length());
  assign_r_1 = count_after(assign_r, ']');
  //cout << assign_r_1;
  if(isdigit(assign_r_1[0]) || assign_r_1[0] == '\'' || assign_r_1[0] == '\"')
  {
    if (map1.count(assign_l) == 0)
      map1.insert(pair <string, string>(assign_l,assign_r_1));
    else
      map1.at(assign_l) = assign_r_1;
  }
  else
  {
    if (map1.count(assign_r_1) != 0)
      map1.insert(pair <string, string>(assign_l,map1.at(assign_r_1)));
    else
      print_line("#error");
  }
  print_line(temp1);
}

{CONCAT}    {
  string assign_r = "";
  string assign_r_1 = "";
  string temp1 = "";
  string assign_l = "";
  string error_msg = "#error";
  for(int j=0; j<yyleng; j++)
  {
    temp1 = temp1 + yytext[j];
  }
  for(int i = 0; i < yyleng; i++){
    if(yytext[i] != '='){
        assign_l = assign_l + yytext[i];
    }
    else{
      break;
    }
  }
  assign_l = removeSpaces(assign_l);
  assign_r = temp1.substr(temp1.find("=") + 1, temp1.length());
  assign_r = removeSpaces(assign_r);
  vector<string> out = split(assign_r, "+");
  list <string> add_list;
  string datatype = "";
  int dt_type = 0;
  for(unsigned p=0; p<out.size(); p++)
  {
    int len = out[p].length();
    if(out[p][0] == '\[')
    {
      string temp = out[p];
      temp = temp.substr(temp.find("[")+1, temp.length());
      string temp_t = "";
      temp_t = count_after(temp, ']');
      if(isdigit(temp_t[0]))
      {
        add_list.push_back(temp_t);
        if (dt_type == 0)
        {
          datatype = "integer";
          dt_type = 1;
        }
        else{
          if (datatype != "integer"){
            print_line(error_msg);
          }
        }
      }
      else if (temp_t[0] == '\'' || temp_t[0] == '\"')
      {
        add_list.push_back(temp_t);
        if (dt_type == 0)
        {
          datatype = "string";
          dt_type = 1;
        }
        else{
          if (datatype != "string"){
            print_line(error_msg);
          }
        }
      }
      else
      {
        if (map1.count(temp_t) != 0)
        {
          add_list.push_back(map1.at(temp_t));
          if (dt_type == 0)
              if(isdigit(map1.at(temp_t)[0]))
              {
                datatype = "integer";
                dt_type = 1;
              }
              else
              {
                datatype = "string";
                dt_type = 1;
              }
          else
          {
            if(isdigit(map1.at(temp_t)[0])){
              if (datatype != "integer"){
                print_line(error_msg);
              }
            }
            else{
              if (datatype != "string"){
                print_line(error_msg);
              }
            }
          }
        }
        else
          print_line("#error");
      }
    }
    else if (out[p][0] == '(')
    {
      if(out[p][1] == '\[')
      {
        string temp = out[p];
        temp = temp.substr(temp.find("\(")+2, temp.length());
        if (temp[0] == '\"')
        {
          string temp_t = "";
          temp_t = count_after(temp, ']');
          add_list.push_back(temp_t);
          if (dt_type == 0)
          {
            datatype = "string";
            dt_type = 1;
          }
          else{
            if (datatype != "string"){
              print_line(error_msg);
            }
          }
        }
        else if (isdigit(temp[0]))
        {
          string temp_t = "";
          temp_t = count_after(temp, ']');
          add_list.push_back(temp_t);
          if (dt_type == 0)
          {
            datatype = "integer";
            dt_type = 1;
          }
          else{
            if (datatype != "integer"){
              print_line(error_msg);
            }
          }
        }
        else
        {
          string temp_t = "";
          temp_t = count_after(temp, ']');
          add_list.push_back(map1.at(temp_t));
          if (dt_type == 0)
          {
            if(isdigit(map1.at(temp_t)[0]))
            {
              datatype = "integer";
              dt_type = 1;
            }
            else
            {
              datatype = "string";
              dt_type = 1;
            }
          }
          else
          {
            if(isdigit(map1.at(temp_t)[0])){
              if (datatype != "integer"){
                print_line(error_msg);
              }
            }
            else{
              if (datatype != "string"){
                print_line(error_msg);
              }
            }
          }
        }
      }
      else
      {
        string temp = out[p];
        temp = temp.substr(temp.find("\(")+1, temp.length());
        if (map1.count(temp) != 0)
          add_list.push_back(map1.at(temp));
        else
          print_line("#error");
      }
    }
    else if (out[p][len-1] == ')')
    {
      string temp = out[p];
      string temp_t = "";
      temp_t = count_after(temp, ')');
      add_list.push_back(map1.at(temp_t));
    }
    else
    {
      if (map1.count(out[p]) != 0)
      {
        add_list.push_back(map1.at(out[p]));
        if (dt_type == 0)
            if(isdigit(map1.at(out[p])[0]))
            {
              datatype = "integer";
              dt_type = 1;
            }
            else
            {
              datatype = "string";
              dt_type = 1;
            }
        else
        {
          if(isdigit(map1.at(out[p])[0]))
          {
            if (datatype != "integer")
              print_line(error_msg);
          }
          else
          {
            if (datatype != "string"){
              print_line(error_msg);
            }
          }
        }
      }
      else
        print_line("#error");
    }
  }
  string add_string = "";
  string comma1 = ",";
  list <string> :: iterator it;
  for(it = add_list.begin(); it != add_list.end(); ++it)
  {
    add_string += *it;
    int length1 = add_string.length();
    add_string.insert(length1, comma1);
  }
  string add_string1 = add_string.substr(0, add_string.size()-1);
  if (map1.count(assign_l) == 0)
  {
    map1.insert(pair <string, string>(assign_l,add_string1));
  }
  else
  {
    map1.at(assign_l) = add_string1;
  }
  print_line(temp1);
}
{IFELSE}  {
  string temp1 = "";
  string temp2 = "";
  for(int j=0; j<yyleng; j++)
  {
    temp2 = temp2 + yytext[j];
  }
  temp1 = removeSpaces(temp2);
  string assign_l = count_after(temp1, '=');
  string assign_r = temp1.substr(temp1.find("=")+1, temp1.length());
  string assign_r_1 = assign_r.substr(assign_r.find("if")+1, assign_r.length());
  //only digit case
  if (isdigit(assign_r_1[0]))
  {
    if(map1.count(assign_l) == 0)
      map1.insert(pair <string, string>(assign_l,assign_r));
    else
      map1.at(assign_l) = assign_r;
  }
  //if-else condition
  else if (assign_r_1[0] == 'f')
  {
    string valueif = count_after(assign_r, 'i');
    string checkvar1 = assign_r.substr(assign_r.find("if")+2, assign_r.length());
    string greater = ">";
    string lesser = "<";
    string equalto = "=";
    string eequalto = "==";
    //cout << assign_l << endl << valueif << endl << checkvar << endl << oprvalue << endl << elvalue << "end";
    if (checkvar1.find(greater) != string::npos)
    {
      string checkvar = count_after(checkvar1, '>');
      string oprvalue1 = checkvar1.substr(checkvar1.find(">")+1, checkvar1.length());
      string oprvalue = count_after(oprvalue1, 'e');
      string elvalue = oprvalue1.substr(oprvalue1.find("e")+4, oprvalue1.length());
      if (isdigit(oprvalue[0]))
      {
        if(map1.at(checkvar)>oprvalue)
          map1.insert(pair <string, string>(assign_l,valueif));
        else
          map1.insert(pair <string, string>(assign_l,elvalue));
      }
      else
      {
        if(map1.at(checkvar)>map1.at(oprvalue))
          map1.insert(pair <string, string>(assign_l,valueif));
        else
          map1.insert(pair <string, string>(assign_l,elvalue));
      }
    }
    else if (checkvar1.find(lesser) != string::npos)
    {
      string checkvar = count_after(checkvar1, '<');
      string oprvalue1 = checkvar1.substr(checkvar1.find("<")+1, checkvar1.length());
      string oprvalue = count_after(oprvalue1, 'e');
      string elvalue = oprvalue1.substr(oprvalue1.find("e")+4, oprvalue1.length());
      if (isdigit(oprvalue[0]))
      {
        if(map1.at(checkvar)<oprvalue)
          map1.insert(pair <string, string>(assign_l,valueif));
        else
          map1.insert(pair <string, string>(assign_l,elvalue));
      }
      else
      {
        if(map1.at(checkvar)<map1.at(oprvalue))
          map1.insert(pair <string, string>(assign_l,valueif));
        else
          map1.insert(pair <string, string>(assign_l,elvalue));
      }
    }
    else if (checkvar1.find(equalto) != string::npos || checkvar1.find(eequalto) != string::npos)
    {
      string checkvar = count_after(checkvar1, '=');
      string oprvalue1 = checkvar1.substr(checkvar1.find("==")+2, checkvar1.length());
      string oprvalue = count_after(oprvalue1, 'e');
      string elvalue = oprvalue1.substr(oprvalue1.find("e")+4, oprvalue1.length());
      if (isdigit(oprvalue[0]))
      {
        if(map1.at(checkvar)==oprvalue)
          map1.insert(pair <string, string>(assign_l,valueif));
        else
          map1.insert(pair <string, string>(assign_l,elvalue));
      }
      else
      {
        if(map1.at(checkvar)==map1.at(oprvalue))
          map1.insert(pair <string, string>(assign_l,valueif));
        else
          map1.insert(pair <string, string>(assign_l,elvalue));
      }
    }
  }
  //only variable case
  else
  {
    if (map1.count(assign_r) != 0)
      map1.insert(pair <string, string>(assign_l,map1.at(assign_r)));
    else
      print_line("#error");
  }
  print_line(temp2);
}
{PRINT}   {
  map<string, string> map2;
  string element1 = "";
  string temp1 = "";
  string element2 = "";
  string element3 = "";
  for(int j=0; j<yyleng; j++)
  {
    temp1 = temp1 + yytext[j];
  }
  element1 = temp1.substr(temp1.find("(") + 1, temp1.length());
  int flag = 0;
  for(int i = 0; i < element1.length(); i++){
    if(element1[i] == '[')
    {
      flag = 1;
      break;
    }
  }
  string value = "";
  int check = 0;
  if (flag == 0)
  {
    element2 = count_after(element1, ')');
    string element4 = "[" + map1.at(element2) + "]";
    map2.insert(pair <string, string>(element2,element4));
  }
  else
  {
    element2 = count_after(element1, '[');
    element3 = element1.substr(element1.find("[")+1, element1.length());
    for(int i = 0; i < element3.length(); i++){
      if(element3[i] == ':'){
          check = 1;
          break;
      }
    }
    string slicing = "";
    int position;
    //if only one value is there, without :
    if (check == 0)
    {
      value = count_after(element3, ']');
      slicing = map1.at(element2);
      //stringstream change(value);
      //change >> position;
      int check1 = 0;
      //if we want first element from that list
      if (value == "0")
      {
        for(int i = 0; i < slicing.length(); i++){
          if(slicing[i] == ','){
              check1 = 1;
              break;
          }
        }
        string result11 = slicing.substr(slicing.find("[")+1, slicing.length());
        string result12 = "";
        //if only 1 element is there
        if (check1 == 0)
        {
          string result111 = result11.substr(0, result11.size()-1);
          map2.insert(pair <string, string>(element2,result111));
        }
        //if more than 1 element is there
        else
        {
          result12 = count_after(result11, ',');
          map2.insert(pair <string, string>(element2,result12));
        }
      }
      //if we want any particular element in list
      else
      {
        for(int i = 0; i < slicing.length(); i++){
          if(slicing[i] == ','){
              check1 = 1;
              break;
          }
        }
        int commas = 0;
        stringstream change(value);
        change >> position;
        string occu = "";
        string result13 = "";
        //if there is only one element in list
        if (check1 == 0)
          map2.insert(pair <string, string>(element2,""));
        //if more than one element is there
        else
        {
          for(int i = 0; i < slicing.length(); i++){
            if(slicing[i] == ','){
                commas += 1;
            }
          }
          if (position <= commas)
          {
            occu = after_occ(slicing, ',', position);
            for(int i = 0; i < occu.length(); i++){
              if(occu[i] != ']' && occu[i] != ','){
                  result13 += occu[i];
              }
              else{
                break;
              }
            }
            map2.insert(pair <string, string>(element2,result13));
          }
          else
          {
            map2.insert(pair <string, string>(element2,""));
          }
        }
      }
    }
    //more than 1 value, with slicing (:)
    else
    {
      value = count_after(element3, ':');
      string slicing = map1.at(element2);
      int position;
      stringstream change(value);
      change >> position;
      string occu = after_occ(slicing, ',', position);
      string occu1 = "[" + occu + "]";
      map2.insert(pair <string, string>(element2,occu1));
    }
  }
  print_line(temp1);
  print_msg(map2);
}

.   {   }

%%
