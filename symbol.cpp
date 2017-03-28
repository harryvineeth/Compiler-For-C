#include <bits/stdc++.h>
using namespace std;

struct symbolTable
{
	/* data */
	string name;
	vector<int> type;
	int addr;
};

map<string,symbolTable> st;
char icg[100][100];

bool lookup(string name)
{
	if(!st.count(name))
		return true;
	else
		return false;
}

void insert(char *n, int type, int addr)
{
	string name(n);
	struct symbolTable sym;
	if(lookup(name))
	{
		
		sym.name = name;
		sym.type.push_back(type);
		sym.addr = addr;
		st[name] = sym;
	}
	else
	{
		sym = st[name];
		if(sym.addr == addr)
		{
			sym.type.push_back(type);
			st[name] = sym;
		}
	}

	return;
}
int top=-1,lno=0,ltop=0;
int lab_tags[20];
char c[10]="0";
char temp[10]="t";
void printsym()
{
	//cout<<"hello"<<endl;
	map<string,symbolTable>::iterator it;
	struct symbolTable s;
	for(it=st.begin();it!=st.end();++it)
	{
		s=it->second;
		cout<<s.addr<<"  "<<s.name<<"  ";
		for(int i=0;i<s.type.size();++i)
			cout<<s.type[i]<<" ";
		cout<<endl;
	}
	return;
}

bool check(string s1, string s2){
	struct symbolTable symbolTable1, symbolTable2;
	symbolTable1 = st[s1];
	symbolTable2 = st[s2];
	return symbolTable1.type[0] == symbolTable2.type[0];
}

bool redeclare(char* name){
	if(!st.count(name))
		return true;
	else
		return false;
}


void store (char* str)
{
	strcpy(icg[++top],str);
}

void assign()
{
	printf("%s = %s\n",icg[top-2],icg[top]);
	top= top-2;
}

void temp_assign()
{
	strcpy(temp,"t");
	strcat(temp,c);
	printf("%s := %s '%s' %s\n",temp,icg[top-2],icg[top-1],icg[top]);
	top=top-2;
	strcpy(icg[top],temp);
	c[0]++;
}

void f_gen1()
{
	printf("F%d: ",lno++ );

}

void f_gen2()
{
	strcpy(temp,"t");
	strcat(temp,c);
	printf("%s=not %s\n",temp,icg[top] );
	printf("if %s goto F%d\n",temp,lno );
	c[0]++;
	lab_tags[++ltop]=lno;
	lno++;
	printf("goto F%d\n",lno );
	lab_tags[++ltop]=lno;
	printf("F%d: ",++lno );

}

void f_gen3()
{
	int x;
	x=lab_tags[ltop--];
	printf("goto F1\n");
	printf("F%d: ",x );
}

void f_gen4()
{
	int x;
	x=lab_tags[ltop--];
	printf("goto F%d\n",lno);
	printf("F%d: ",x );
}

void w_gen1()
{
	printf("W%d: ",lno++ );
}

void w_gen2()
{
	strcpy(temp,"t");
	strcat(temp,c);
	printf("%s=not %s\n",temp,icg[top] );
	printf("if %s goto W%d\n",temp,lno );
	c[0]++;
}

void w_gen3()
{
	printf("goto W1\n");
	printf("W%d: ",lno);
}

void if_gen1()
{
	lno++;
	strcpy(temp,"t");
	strcat(temp,c);
	printf("%s=not %s\n",temp,icg[top] );
	printf("if %s goto IF%d\n",temp,lno );
	c[0]++;
	lab_tags[++ltop]=lno;
}

void if_gen2()
{
	int x;
	lno++;
	x=lab_tags[ltop--];
	printf("goto IF%d\n",lno);
	printf("IF%d: ",x );
	lab_tags[++ltop]=lno;
}

void if_gen3()
{
	int z;
	z=lab_tags[ltop--];
	printf("IF%d\n",z );
}