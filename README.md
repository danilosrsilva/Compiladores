# Compiladores – flacmp

Repositório desenvolvido para a disciplina de Compiladores, contendo a implementação de um compilador inicial com **analisador léxico**, **analisador sintático** e **analisador semântico**.

## flacmp – A Flalinguagem

Durante a disciplina, cada aluno deveria projetar sua própria linguagem para servir de base ao compilador. Como torcedor apaixonado pelo Flamengo, desenvolvi a **flalinguagem**, uma linguagem temática cuja sintaxe e palavras-chave fazem referência ao universo rubro-negro.

A linguagem oferece:

- Declaração e atribuição de variáveis  
- Tipos básicos: `INT`, `FLT`, `STR`  
- Estruturas condicionais: `IF` e `IF-ELSE`  
- Estrutura de repetição: `WHILE`  
- Impressão de valores com `FLAPRINT`  
- Blocos delimitados por `FLA` e `MENGO`  
- Comentários iniciados com a palavra-chave `DIDI`

O compilador flacmp realiza todas as etapas fundamentais:

- **Análise léxica:** identificação de tokens da flalinguagem  
- **Análise sintática:** construção da árvore sintática abstrata (AST)  
- **Análise semântica:** verificação de variáveis não declaradas, redeclarações, uso indevido e variáveis não inicializadas  
