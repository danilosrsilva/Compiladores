
#include<vector>
#include<string>
#include<iostream>
#include<set>
extern int yylineno;
//usa o map para armazenar chave e valor para validar semantica de validar variavel mas nao esta sendo usada; registrartipo para avisar erro
using namespace std;

class Program;

class Node {
	protected:
		vector<Node*> children;
		int lineno;

	public:
		Node() {
			lineno = yylineno;
		}

		int getLineNo() {
			return lineno;
		}

		void append(Node *n) {
			children.push_back(n);
		}
		
		vector<Node*>& getChildren(){
		return children;
		}
		
		virtual string astLabel(){
			return "";
		}
		friend class Program;
    
};

class Load: public Node {
	protected:
		string name;
	public:
		Load(string name) {
			this->name = name;
		}
		string astLabel() override {
		return name;
		}
		string getName(){
		return name;
		}
};

class Store: public Node {
	protected:
		string name;
	public:
		Store(string name, Node *expr) {
			this->name = name;
			this->append(expr);
		}
		string astLabel() override {
		string r;
		r.append("store ");
		r.append(name);
		return r;
		}
		
		string getName(){
			return name;
		}
};

class ConstInteger: public Node {
	protected:
		int value;
	public:
		ConstInteger(int value) {
			this->value = value;
		}
		string astLabel() override {
		return to_string(value);
		}
};

class ConstDouble: public Node {
	protected:
		double value;
	public:
		ConstDouble(double value) {
			this->value = value;
			
		}
		string astLabel() override {
		return to_string(value);
		}
};

class BinaryOp: public Node {
	protected:
		char oper;
	public:
		BinaryOp(Node *left, char oper, Node *right) {
			this->oper = oper;
			this->append(left);
			this->append(right);
			}
			string astLabel() override {
		string r;
		r.push_back(oper);
		return r;
		}
};

class Print :  public Node{
	protected:
	public:
		Print(Node *expr){
			this->append(expr);
			}
			
		string astLabel() override {
		string r;
		r.append("print ");
		r.append(children[0]->astLabel());
		return r;
		}
};

class While: public Node {
public:
    While(Node *logical, Node *stmts) {
        this->append(logical); // children[0] = condição do while
        this->append(stmts);   // children[1] = bloco de comandos
    }

    string astLabel() override {
        return "while";
    }
};

class Condicional: public Node {
protected:
    string oper;
public:
    Condicional(Node *le, const string &op, Node *re) {
        this->oper = op;
        this->append(le); // children[0] = expressão da esquerda
        this->append(re); // children[1] = expressão da direita
    }

    string astLabel() override {
        return oper;
    }
};


class Stmts :  public Node{
	protected:
	public:
		Stmts(Node *expr){
			this->append(expr);
			}
		string astLabel() override {
		return "stmts";
		}
};

class Program: public Node{
	protected:
		void printAstRecursive(Node *n){
		
			//declara no da arvore no graph
			cout << "N" << (long)(n) << 
			"[label=\""<< n->astLabel()<< "\"" <<
			"]\n";
			for(Node *c: n->children){
			cout << "N" << (long) (n) << "--" <<
				"N" << (long) (c) << "\n";
				printAstRecursive(c);
			}
		}
	public:
		Program(Node *stmts){
			this->append(stmts);
		}
		void printAst(){
			cout << "graph {\n";
			cout << "N" << (long)(this)
			<< "[label=\"Program\"]\n";
			cout << "N" << (long)(this) << " -- "
			<< "N" << (long)(children[0])
			<< "\n";
			
			printAstRecursive(children[0]);
			cout << "}\n";
		}
		
		string astLabel() override {
			return "program";
		}
	};

class SemanticVarDecl {
	private:
		set<string> vars;
	public:
		void check(Node *n){
			for(Node *c: n->getChildren()){
				check(c);
			}
			
			Store *store = dynamic_cast<Store*>(n);
			if(store != NULL){
				vars.insert(store->getName());
			}
			Load *load = dynamic_cast<Load*>(n);
			if(load != NULL ){
				string vname = load->getName();
				if(vars.count(load->getName()) ==0){
					extern char* build_file_name;
					cerr << build_file_name << ":" << load->getLineNo() << ": ";
					cerr << "Var " << vname << " not found.\n";
				}
			}
		}
		// usar cout e vars com <<
		void printFoundVars(){
			for(string v : vars){
			cout << "Found: " << v << "\n";
			}
		}
};
