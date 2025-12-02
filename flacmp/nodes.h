// nodes.h - atualizado
#include <map>
#include <vector>
#include <string>
#include <iostream>
#include <set>
extern int yylineno;
// usa o map para armazenar chave e valor para validar semantica de validar variavel mas nao esta sendo usada; registrartipo para avisar erro
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
        if (n) children.push_back(n);
    }

    vector<Node*>& getChildren(){
        return children;
    }

    virtual string astLabel(){
        return "";
    }
    friend class Program;
};

// Casos onde variavel é instanciada LoadDecl
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

// Casos onde variavel receber algum valor 
// (parece ser usado como atribuição ou declaração com expressão)
class LoadComValor: public Node {
protected:
    string name;
public:
    LoadComValor(string name, Node *expr) {
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

// Registra variaveis declaradas já com valor
class Store: public Node {
protected:
    string name;
    string type;
    bool usado;
public:
    Store(string name,const string &type, Node *expr) {
        this->name = name;
        this->type = type;
        this->usado = true; 
        if (expr) this->append(expr);
    }

    string astLabel() override {
        return "decl: " + type + ": " + name;
    }

    string getName(){
        return name;
    }

    string getType(){
        return type;
    }

    bool getUsado(){
        return usado;
    }

    void setUsado(bool usado) {
        this->usado = usado;
    }
};

// Registra variaveis declaradas (sem valor)
class StoreSemValor: public Node {
protected:
    string name;
    string type;
    bool usado;
public:
    StoreSemValor(string name,const string &type) {
        this->name = name;
        this->type = type;
        this->usado = false;
    }

    string astLabel() override {
        return "decl: " + type + ": " + name;
    }

    string getName(){
        return name;
    }

    string getType(){
        return type;
    }

    bool getUsado(){
        return usado;
    }

    void setUsado(bool usado) {
        this->usado = usado;
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
        if (!children.empty()) r.append(children[0]->astLabel());
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

class IFELSE: public Node {
	protected:
	public:
		IFELSE(Node *logical, Node *stmtsIf, Node *stmtsElse) {
			this->append(logical);
			this->append(stmtsIf);
			this->append(stmtsElse);
		}

		string astLabel() override {
			return "IFELSE:";
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

        // declara no da arvore no graph
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
        cout << "================================\n\n";
        cout << "graph {\n";
        cout << "N" << (long)(this)
        << "[label=\"Program\"]\n";
        if (!children.empty()) {
            cout << "N" << (long)(this) << " -- "
            << "N" << (long)(children[0])
            << "\n";
            printAstRecursive(children[0]);
        }
        cout << "}\n";
    }

    string astLabel() override {
        return "program";
    }
};


// Validacao semantica de declaracao, redeclaração, uso e inicializacao de variaveis
class ValidacaoSemanticas {
private:
    struct VarInfo {
        Node* node;      
        bool usada;      
        bool inicializada; 
        string tipo;     
    };

    map<string, VarInfo> vars; // mapa de variáveis declaradas

public:

    void check(Node *n){
        if (!n) return;

        for (Node *c : n->getChildren()) {

            
            if (Store *store = dynamic_cast<Store*>(c)) {
                string name = store->getName();

                if (vars.count(name) > 0) {
                    extern char *build_file_name;
                    cerr << (build_file_name ? build_file_name : "")
                         << ":" << store->getLineNo() << ": "
                         << "Semantic error: variável '" << name
                         << "' já foi declarada.\n";
                } else {
                    VarInfo info;
                    info.node = store;
                    info.usada = false; 
                    info.inicializada = true; 
                    info.tipo = store->getType();
                    vars[name] = info;
                }
            }
            
            else if (StoreSemValor *storesv = dynamic_cast<StoreSemValor*>(c)) {
                string name = storesv->getName();

                if (vars.count(name) > 0) {
                    extern char *build_file_name;
                    cerr << (build_file_name ? build_file_name : "")
                         << ":" << storesv->getLineNo() << ": "
                         << "Semantic error: variável '" << name
                         << "' já foi declarada.\n";
                } else {
                    VarInfo info;
                    info.node = storesv;
                    info.usada = false; 
                    info.inicializada = false; 
                    info.tipo = storesv->getType();
                    vars[name] = info;
                }
            }

          
            else if (Load *load = dynamic_cast<Load*>(c)) {
                string vname = load->getName();
                if (vars.count(vname) == 0) {
                    extern char* build_file_name;
                    cerr << (build_file_name ? build_file_name : "")
                         << ":" << load->getLineNo() << ": "
                         << "Semantic error: variável '" << vname
                         << "' não declarada.\n";
                } else {
                
                    vars[vname].usada = true;
                }
            }
            
            else if (LoadComValor *loadcomvalor = dynamic_cast<LoadComValor*>(c)) {
                string vname = loadcomvalor->getName();
                if (vars.count(vname) == 0) {
                    extern char* build_file_name;
                    cerr << (build_file_name ? build_file_name : "")
                         << ":" << loadcomvalor->getLineNo() << ": "
                         << "Semantic error: variável não declarada '"
                         << vname << "'.\n";
                } else {
                    
                    vars[vname].inicializada = true;
                    vars[vname].usada = true;
                }
            }

    
            check(c);
        }
    }

    // verifica variáveis que foram declaradas mas nunca inicializadas
    void VerificaInicializacao() {
        for (const auto& pair : vars) {
            const string& varName = pair.first;
            const VarInfo& info = pair.second;

            if (!info.inicializada) {
                extern char *build_file_name;
                cerr << (build_file_name ? build_file_name : "")
                     << ":" << info.node->getLineNo() << ": "
                     << "Semantic error: variável '" << varName
                     << "' foi declarada mas nunca recebeu valor (não inicializada).\n";
            }
        }
    }

    void VariavelUsada() {
        for (const auto& pair : vars) {
            const string& varName = pair.first;
            const VarInfo& info = pair.second;

            if (!info.usada) {
                extern char *build_file_name;
                cerr << (build_file_name ? build_file_name : "")
                     << ":" << info.node->getLineNo() << ": "
                     << "Warning: variável '" << varName
                     << "' do tipo '" << info.tipo
                     << "' foi declarada mas não utilizada.\n";
            }
        }
    }
};
