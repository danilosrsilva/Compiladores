
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

//Casos onde variavel é instanciada 
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

//Casos onde variavel receber algum valor 
// --- Load2: representa atribuição/uso de variável (ex.: x = expr) ---
class Load2: public Node {
protected:
    string name;
public:
    Load2(string name, Node *expr) {
        this->name = name;
        if (expr) this->append(expr);
    }

    string astLabel() override {
        return name;
    }

    string getName(){
        return name;
    }
};


// Registra variaveis declaradas
class Store: public Node {
	protected:
		string name;
		string type;
	public:
		Store(string name,const string &type, Node *expr) {
			this->name = name;
			this->type = type;
			this->append(expr);
		}
		// string astLabel() override {
		// string r;
		// r.append("store ");
		// r.append(name);
		// return r;
		// }

		string astLabel() override {
        return "decl: " + type + ": " + name;
    	}
		
		string getName(){
			return name;
		}

		string getType(){
			return type;
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

class ConstString : public Node
{
protected:
    string value;

public:
    ConstString(string value)
    {
        this->value = value;
    }

    string astLabel() override
    {
        return value;
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
		r.append("print: ");
		r.append(children[0]->astLabel());
		return r;
		}
};

class While: public Node {
	protected:
	public:
		While(Node *logical, Node *stmts) {
			this->append(logical); 
			this->append(stmts);  
		}

		string astLabel() override {
			return "while:";
		}
};

class IF: public Node {
	protected:
	public:
		IF(Node *logical, Node *stmts) {
			this->append(logical); 
			this->append(stmts);  
		}

		string astLabel() override {
			return "IF:";
		}
};


class Logico: public Node {
protected:
    string oper;
public:
    Logico(Node *le, const string &op, Node *re) {
        this->oper = op;
        this->append(le); 
        this->append(re); 
    }

    string astLabel() override {
        return oper;
    }
};

class Condicional: public Node {
protected:
    string oper;
public:
    Condicional(Node *le, const string &op, Node *re) {
        this->oper = op;
        this->append(le); 
        this->append(re); 
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
    set<string> vars; // mantém as variáveis declaradas

public:
    void check(Node *n){
        for (Node *c : n->getChildren()) {

            // 1) verificação para declaração (Store)
            if (Store *store = dynamic_cast<Store*>(c)) {
                string name = store->getName();

                // se já existir na tabela: ERRO
                if (vars.count(name) > 0) {
                    extern char *build_file_name;
                    cerr << (build_file_name ? build_file_name : "") 
                         << ":" << store->getLineNo() << ": "
                         << "Semantic error: variable '" << name 
                         << "' already declared.\n";
                } else {
                    vars.insert(name); // registra declaração
                }
            }

            // 2) verificação para uso (Load)
            else if (Load *load = dynamic_cast<Load*>(c)) {
                string vname = load->getName();
                if (vars.count(vname) == 0) {
                    extern char* build_file_name;
                    cerr << (build_file_name ? build_file_name : "") 
                         << ":" << load->getLineNo() << ": "
                         << "Semantic error: variable '" << vname 
                         << "' not declared.\n";
                }
            }

            // 3) verificação para uso (Load2 - atribuição)
            else if (Load2 *load2 = dynamic_cast<Load2*>(c)) {
                string vname = load2->getName();
                if (vars.count(vname) == 0) {
                    extern char* build_file_name;
                    cerr << (build_file_name ? build_file_name : "") 
                         << ":" << load2->getLineNo() << ": "
                         << "Semantic error: assignment to undeclared variable '" 
                         << vname << "'.\n";
                }
            }

            // 4) descida recursiva
            check(c);
        }
    }
};


