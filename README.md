# Abap Workshop
    Intensive ABAP workshop exploring fundamentals and practices in the SAP ERP environment.

## Comandos e Transações (Outside-Code)

- **/o(transação):**  Cria outra janela
- **/n(transação):**  Cancela a transação atual e executa a próxima. Perde-se os dados não salvos
- **SE38:** Pesquisar/criar/editar programas.
- **SE91:** Criar Classe de Mensagens.
- Menu "Ir Para > Tradução": Traduzir textos.
- **SE11:** Visualizar estrutura de tabelas.
- **SE16/SE16N:** Consultar conteúdo de tabelas.
- **SE37:** módulos de função
- **SE80:** object navigator
- **J1B3N:** Consulta nota fiscal
- **SN30:** Quando criar tabela, criar dados para inserção em tabelas existentes
- F5 entra na rotina. F6 executa.
- CTRL+’/’ exibe a lista de atributos de um objeto no editor do ABAP GUI
- **Domínio e Elemento de Dados:** O SAP usa rotinas de conversão para armazenar e exibir dados em formatos diferentes.
- **Uso de Foreign Keys:** Controle de referência feito pelo SAP, sem chaves estrangeiras físicas nos bancos.
- **CTRL+F1:** O acesso ao ABAP glossary, para consultar a documentação
- F4: acionar a ajuda de pesquisa (match-code, search help)
- Tabela dicionário ≠ Tabela SGBD
Tabela dicionário é utilizada para atribuir à variáveis tipos já existentes, para não reinventar a roda. Já a tabela de SGBDs é utilizada para
- O acesso ao ABAP glossary, para consultar a documentação, é feito pelo atalho CTRL+F1
- Tipo N → Campo de DÍGITOS (Caracteres no intervalo [0-9]).
- Abapgit para versionamento.
- SM30  é o mesmo que ZUSURED_08
- SE80 para criar um programa online

## Atalhos (Inside-Code)

- **CTRL+F1:** Alterna entre o modo de visualização e modificação do código.
- **CTRL+F2:** Verificar sintaxe.
- **CTRL+F3:** Ativar o programa (1 - verifica sintaxe; 2 - compila; 3 - grava)
- **F5:** Editar símbolos de texto e texto de seleção, abre o editor de Elemento de Textos:
    1. Símbolos de texto: Muda as variáveis de texto. Ex: TEXT-002 = “Datas”.
    2. Textos de seleção: Edita os nomes dos parâmetros que Da tela de seleção do usuário (input).
    3. Títulos de Lista: Mínima ideia ainda.
- **F8:** Executa o programa.
- **CTRL+S:** Salva o código.

## Estrutura de um Programa:

1. **REPORT:** Nomeia o programa.
2. **DATA:** Declaração de variáveis.
3. **PARAMETERS:** Input pelo usuário.
4. **INITIALIZE:** Inicializa variáveis com um valor.
5. **START-OF-SELECTION:** Executado após a tela de seleção padrão (após apertar F8).
6. **AT SELECTION-SCREEN:** Evento usado para validações.
7. **END-OF-SELECTION:** Finaliza o processamento do programa.

## Variáveis Nativas

- **SY-UNAME:** Código do usuário (usuário de logon do SAP).
- **SY-DATUM:** Data atual.
- **SY-UZEIT:** Hora atual.
- **SY-REPID:** Nome do programa.
- **SY-TCODE:** Transação em execução.

## Prefixos/Padrão de Nomenclatura:

| Prefixo | Tipo/Propósito                          | Exemplo               |
|---------|-----------------------------------------|-----------------------|
| `v_`    | Variável comum (geral)                  | `v_data`             |
| `t_`    | Tabela interna                          | `t_table`            |
| `tp_`   | Tipos (Types)                           | `tp_tipo`            |
| `lv_`   | Variável local (Local Variable)         | `lv_counter`         |
| `gv_`   | Variável global (Global Variable)       | `gv_total`           |
| `lt_`   | Tabela interna (Local Table)            | `lt_sales`           |
| `gt_`   | Tabela interna global                   | `gt_customers`       |
| `ls_`   | Estrutura (Local Structure)             | `ls_employee`        |
| `gs_`   | Estrutura global                        | `gs_order`           |
| `lf_`   | Field-Symbols (Símbolo de Campo)        | `lf_field`           |
| `cf_`   | Field-Symbols globais                   | `cf_value`           |
| `lr_`   | Referência (Local Reference)            | `lr_object`          |
| `gr_`   | Referência global                       | `gr_service`         |
| `wa_`   | Work Area                               | `wa_customer`        |
| `it_`   | Tabela interna                          | `it_data`            |
| `iv_`   | Parâmetro de entrada (Input Variable)   | `iv_name`            |
| `ev_`   | Parâmetro de saída (Export Variable)    | `ev_result`          |
| `cv_`   | Parâmetro de alteração (Changing Var.)  | `cv_flag`            |
| `p_`    | Parâmetro em geral (Parameter)          | `p_date`             |
| `c_`    | Constante                               | `c_pi`               |
| `z_`    | Customização (obj/var do cliente)       | `z_program`          |

## Operadores

| Operator | Meaning                                                                 |
|----------|-------------------------------------------------------------------------|
| =, EQ    | Equal: True if the value of *operand1* matches the value of *operand2*. |
| <>, NE   | Not Equal: True if the value of *operand1* does not match the value of *operand2*. |
| <, LT    | Less Than: True if the value of *operand1* is less than the value of *operand2*. |
| >, GT    | Greater Than: True if the value of *operand1* is greater than the value of *operand2*. |
| <=, LE   | Less Equal: True if the value of *operand1* is less than or equal to the value of *operand2*. |
| >=, GE   | Greater Equal: True if the value of *operand1* is greater than or equal to the value of *operand2*. |


# Código ABAP

---
## REPORT

Inicializa e nomeia o programa.

```abap
REPORT znome_do_programa.
```

## COMENTÁRIOS

Comentários em bloco e em linha. 

- **CTRL+Vírgula (’ , ‘):** Comenta o bloco de código selecionado.
- **CTRL+Ponto (’ . ‘):** Descomenta o bloco de código selecionado.

```abap
****************************************************************
* REPORT znome_do_programa.
****************************************************************
* 23/01/2025 - Programa teste
****************************************************************
```

```abap
REPORT znome_do_programa. "Isso é um comentário
```

## DATA

Declaração de variáveis não inicializadas.

```abap
DATA v_variavel TYPE i.
```

```abap
DATA: v_numero    TYPE i VALUE 10,
            v_nome(20)  TYPE c,
            v_sobrenome TYPE c LENGTH 20,
            v_data      TYPE sy_datum.

```

## PARAMETERS

Declaração de variáveis inicializadas pelo usuário (input). Não podem ter mais de 8 dígitos.

```abap
PARAMETERS v_myname(20) TYPE c.
```

```abap
PARAMETERS: v_idade   TYPE i,
                        v_dtnasc  TYPE sy_datum,
                        v_is_ok   AS CHECKBOX.
```

## CONSTANTS

Inicializar e atribuir valores constantes.

```abap
CONSTANTS: c_produto_acabado TYPE mara_mtart VALUE 'FERT'.
```

## WRITE

Escrever algum texto ou variável na tela.

```abap
WRITE v_data_nasc.

**"""""""OUTPUT"""""""
"** 16.12.2005
**""""""""""""""""""""**
```

```abap
WRITE: / 'Olá mundo'.
WRITE: / 'Meu nome é', v_seu_nome, / 'eu tenho', v_idade, 'anos.'.
WRITE: / '.'.
WRITE: / | Meu nome é {v_seu_nome} |, / | eu tenho {v_idade} anos.|.

**"""""""OUTPUT"""""""
"** Olá mundo
**"** Meu nome é Pedro
**"** eu tenho 20 anos.
**"** .
**"** Meu nome é Pedro
**"** eu tenho 20 anos.
**""""""""""""""""""""**
```

## IF, ELSEIF, ELSE, ENDIF

Condicional (Inicia e termina com IF e ENDIF)

```abap
DATA v_idade TYPE i VALUE 20.

IF v_idade >= 19. "True
    WRITE 'Maior de idade'.
ELSEIF v_idade = 18.
    WRITE 'Na risca'.
ELSE.
    WRITE 'Menor de idade'.
ENDIF.

**"""""""OUTPUT"""""""
"** Maior de idade
**""""""""""""""""""""**
```

## DO, ENDDO

Laço de Repetição (Inicia e termina com DO e ENDDO), sy-index = Index iniciando de 1 (1, 2, 3…)

```abap
DO 4 TIMES.
    WRITE: / 'Índice', sy-index.
ENDDO.

**"""""""OUTPUT"""""""
"** Índice 1
**"** Índice 2
**"** Índice 3
**"** Índice 4
**""""""""""""""""""""**
```

## LOOP, ENDLOOP

Laço de Repetição (Inicia e termina com LOOP e ENDLOOP). Lopando dentro das linhas da tabela.

```abap
LOOP AT it_scustom INTO wa_scustom.
  WRITE: / 'ID:', wa_scustom-vtp_scustom_id, ' | ',
           'Nome:', wa_scustom-vtp_scustom_name, ' | ',
           'Cidade:', wa_scustom-vtp_scustom_city.
ENDLOOP.
```

```abap
LOOP AT lt_item_nf INTO l_item_nf. "Loop pelas linhas de uma tabela.

  WRITE:  / 'Nota fiscal', l_item_nf-docnum,
            / 'Item:', l_item_nf-itmnum,
            / 'Data NF:', l_item_nf-docdat,
            / 'Material', l_item_nf-matnr,
            / 'Quantidade', l_item_nf-menge, l_item_nf-meins.
  SKIP.

ENDLOOP.
```

## IS INITIAL

Utilizado para perguntar se uma varável está no seu estado INICIAL.

```abap
IF v_variavel IS INITIAL.
    WRITE: / 'Está no seu estado inicial'.
ENDDO.
```

## TYPES

Tipos customizáveis.

```abap
TYPES: quantidade_estoque TYPE mchb-clabs,
             preco_liquido      TYPE ekpo-netwr.
```

```abap
TYPES: BEGIN OF y_pedido,
                    numero(8)    TYPE n,
                    cliente(40)  TYPE c,
                    preco_total  TYPE ekpo-netwr,
                    data_entrega TYPE sy-datum,
             END OF y_pedido.
```

```abap
TYPES: BEGIN OF tp_custom,
         vtp_scustom_ID   TYPE scustom-id,
         vtp_scustom_name TYPE scustom-name,
         vtp_scustom_city TYPE scustom-city,
       END OF tp_custom.
```

```abap
TYPES: BEGIN OF s_user,
         nome   TYPE c LENGTH 20,
         cidade TYPE c LENGTH 20,
         idioma TYPE c LENGTH 1,
       END OF s_user.
       
DATA: usuario_1 TYPE s_user.
CLEAR usuario_1 "Limpar a variavel
```

## QUERY

Fazendo uma query na tabela de SGBD mara e jogando os dados na estrutura material2:

```abap
SELECT SINGLE *
FROM mara
INTO material2
WHERE matnr = '000020000392'.

WRITE: / 'Tipo de Material', material2-mtart.
```

```abap
SELECT SINGLE carrid
  FROM scarr
  INTO v_scarr_carrid
  WHERE carrid = v_cid.
v_query_id = sy-subrc. "=0: found / <>0: not found
```

```abap
SELECT id, name, city
  FROM scustom
  INTO TABLE @it_scustom
  WHERE id IN @v_cid.
PERFORM f_command_status USING sy-subrc.
```

```abap
TYPES: BEGIN OF s_user,
         nome   TYPE c LENGTH 20,
         cidade TYPE c LENGTH 20,
         idioma TYPE c LENGTH 1,
       END OF s_user.

DATA: v_utmp TYPE s_user.

SELECT SINGLE name, city, langu
      FROM scustom  "Tabela interna
      INTO @v_utmp
      WHERE id = @v_idclnt.
      
IF sy-subrc = 0. " Se sy-subrc=0: QuerySem erros 
* SY-SUBRC: status de comando (testar imediatamente após o comando)

  WRITE: / |Nome: { v_utmp-nome } |,
         / |Cidade: { v_utmp-cidade }|,
         / |Idioma: { v_utmp-idioma } |.
ELSE.
  WRITE: |Cliente { v_idclnt } não encontrado.|.
ENDIF.
```

```abap
  FIELD-SYMBOLS <item> TYPE y_item_nf. " Cabeçalho

  SELECT j_1bnflin~docnum
         j_1bnflin~itmnum
         j_1bnfdoc~docdat
         j_1bnflin~matnr
         j_1bnflin~menge
         j_1bnflin~meins
    FROM j_1bnfdoc
    INNER JOIN j_1bnflin
      ON j_1bnfdoc~docnum = j_1bnflin~docnum
    INTO TABLE lt_item_nf
    WHERE j_1bnfdoc~docnum IN s_nf.
```

```abap
SELECT SINGLE carrid
  FROM scarr
  INTO v_scarr_carrid
  WHERE carrid = v_cid. "WHERE (coluna da tabela) = (variavel local).
" A ordem é essa: SELECT + FROM + INTO + WHERE.
```

```abap
FORM f_command_status USING f_operation_id TYPE i.
  IF f_operation_id = 0.
    WRITE: / |Operação executada com sucesso!|.
  ELSE.
    WRITE: / |Não foi possível executar a operação.|.
  ENDIF.
ENDFORM.

*** QUERY QUALQUER
PERFORM f_command_status USING sy-subrc. "Utilizar essa rotina logo após a querry.
```

## MESSAGE

Exibe mensagens personalizadas.

```abap
IF v_idade < 18.
  MESSAGE 'Idade insuficiente!' TYPE 'E'.
ENDIF.
```

```abap
AT SELECTION-SCREEN.

  IF v_dt_fim < v_dt_ini.
    MESSAGE e002(z08) WITH v_dt_fim v_dt_ini. "ERRO: Data final deve ser >= à inicial.
    STOP.
  ENDIF.
  
* z08 é a classe de mensagens, e002 é a 3º mensagem dentro de z08.
* "ERRO: Data final &1 deve ser >= à inicial &2." (Msg 002 dentro de z08)
* No caso acima, v_dt_fim v_dt_ini subsitituirão respectivamente &1 e &2.
```

## FUNÇÕES / ROTINAS

Modularização: Funções/Subrotinas que recebem argumentos e retornam valores.

```abap
*** CRIAR A FUNÇÃO 
FORM retornar_data
  USING lv_data_input     TYPE sy-datum
        lv_type_out       TYPE i

  CHANGING lv_dia_output  TYPE c
           lv_mes_output  TYPE c
           lv_ano_output  TYPE c.

  lv_ano_output = lv_data_input+0(4).
  lv_dia_output = lv_data_input+6(2).
  lv_mes_output = lv_data_input+4(2)

  IF lv_type_out = 1.
    lv_mes_output = to_upper( lv_mes_output+0(3) ).
  ENDIF.

  IF lv_type_out = 3.
    lv_mes_output = lv_mes_output+0(3).
  ENDIF.
ENDFORM.

*** EXECUTAR A FUNÇÃO
PERFORM retornar_data USING v_dt_ini 1 CHANGING v_dia_temp v_mes_temp v_ano_temp.
WRITE: / 'Início:', v_dia_temp, '/', v_mes_temp, '/', v_ano_temp.

**"""""""OUTPUT"""""""
"** Início: 24 / 01 / 2025
**""""""""""""""""""""**
```

## CONCATENATE

Concatenar strings em uma nova variável.

```abap
CONCATENATE v_nome+0(1) v_sbnome INTO v_new_cod_user.
```

## CONDENSE

Remove os espaços em brancos (no inicio, final, e espaços redundantes) de uma string.

```abap
CONCATENATE v_nome+0(1) v_sbnome INTO v_new_cod_user.
```

## STRLEN

Retorna o tamanho de uma string.

```abap
DATA: v_nome(8)     TYPE c,
            v_nome_length TYPE i.
    
v_nome = 'abcdefgh'.
v_nome_length	= STRLEN( v_nome ). "v_nome_length = 8
```

## SUBSTRING

Obtém uma substring de uma string+n(m) → Pula n dígitos, logo após seleciona m dígitos.

```abap
WRITE: v_nome+2(5).

**"""""""OUTPUT"""""""
"** cdefg
**""""""""""""""""""""**

v_nome_length_minus2 = v_nome_length-2.  "x=8-2, x=6
WRITE: v_nome+v_nome_length_minus2(2).   "v_nome+6(2) , 2 últimos caracteres.

**"""""""OUTPUT"""""""
"** gh
**""""""""""""""""""""**
```

## SKIP. ULINE

Adiciona um espaço (SKIP.) e uma linha (ULINE.) logo após.

```abap
SKIP. 
ULINE.

**"""""""OUTPUT"""""""
" 
"** __________________
**""""""""""""""""""""**
```

## CASE / WHEN / ENDCASE

Switch case, evita vários IF e ELSE (Inicia com CASE, possui vários WHEN, termina com ENDCASE).

```abap
CASE v_data_hoje+4(2).  "v_data_hoje=2024.11.17, v_data_hoje+4(2)=11
  WHEN '01'.
    v_data_month = 'JANEIRO'.
  WHEN '02'.
    v_data_month = 'FEVEREIRO'.
* ... 
  WHEN '11'. "True
    v_data_month = 'NOVEMBRO'.
  WHEN '12'.
    v_data_month = 'DEZEMBRO'.
ENDCASE.

WRITE: / v_data_month.

**"""""""OUTPUT"""""""
"** NOVEMBRO
**""""""""""""""""""""**
```

## MOD

Função módulo, retorna o resto da divisão (%).

```abap
IF v_ano_ini MOD 4 = 0 AND v_ano_ini MOD 100 <> 0.
  WRITE: / v_ano_ini, 'é ano bissexto'.
ENDIF.

**"""""""INPUT""""""""**
**"** v_ano_ini = 2004
**"""""""OUTPUT"""""""
"** 2004 é ano bissexto.
**""""""""""""""""""""**

**"""""""INPUT""""""""**
**"** v_ano_ini = 1900
**"""""""OUTPUT"""""""
"** 
**""""""""""""""""""""**
```

## SELECTION-SCREEN BEGIN OF BLOCK _ WITH FRAME TITLE _

Cria um bloco com o cabeçario de um texto definido.

```abap
SELECTION-SCREEN BEGIN OF BLOCK b_input WITH FRAME TITLE text-001.
  PARAMETERS: v_cid   TYPE scarr-carrid OBLIGATORY,
              v_cname TYPE scarr-carrname,
              v_url   TYPE scarr-url.
SELECTION-SCREEN END OF BLOCK b_input.
```

## SELECT-OPTIONS

Cria um bloco com o cabeçario de um texto definido.

```abap
DATA: tp_scustom_id TYPE scustom-id.

SELECTION-SCREEN BEGIN OF BLOCK b_input WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS v_cid FOR tp_scustom_id OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b_input.
```

## RADIOBUTTON/CHECKBOX

Radiobutton: Opção única, Checkbox: Múltiplas opções.

```abap
SELECTION-SCREEN BEGIN OF BLOCK radios WITH FRAME TITLE TEXT-002.
  PARAMETERS:
    v_radio1 RADIOBUTTON GROUP rdgp DEFAULT 'X',
    v_radio2 RADIOBUTTON GROUP rdgp,
    v_radio3 RADIOBUTTON GROUP rdgp,
    v_check1 AS CHECKBOX,
    v_check2 AS CHECKBOX,
    v_check3 AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK radios.
```

## POPUP_CONTINUE_YES_NO

Exibir tela de confirmação (SIM ou NÃO)
**SE37:** módulos de função
**SE80:** object navigator

```abap
DATA: v_resposta TYPE char1.

CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
    EXPORTING

        textline1 = 'DESEJA EXCLUIR O REGISTRO?'
        Texline2 = 'OBS: OPERAÇÃO SEM RETORNO'
        title1 = 'CONFIRME'

    IMPORTING
        ANSWER = v_resposta
        
if V_RESPOSTA = 'J' "OBS: Sim = "J" e Não = "N"
        "DELETE...
ENDIF.
```

Função RFC: Remote Function Call

## INSERT

Inserir dados em uma tabela interna.

```abap
FORM f_create USING f_carr TYPE tp_carr.
  INSERT INTO scarr
  VALUES @( VALUE #(
    carrid   = f_carr-vtp_cid
    carrname = f_carr-vtp_cname
    url      = f_carr-vtp_url ) ).
  PERFORM f_command_status USING sy-subrc.
ENDFORM.
```

```abap
INSERT demo_expressions FROM TABLE @( VALUE #( 
( id = 'X' num1 = 1 num2 = 10 ) 
( id = 'Y' num1 = 2 num2 = 20 ) 
( id = 'Z' num1 = 3 num2 = 30 ) ) ). 
```

```abap
INSERT v_l_bdcdata_tmp INTO it_bdcdata INDEX 1.

APPEND v_l_bdcdata_tmp TO it_bdcdata.
```

## MODIFY/UPDATE

Alterar dados de uma tabela (UPDATE: Se não existir, cria. MODIFY: Se não existir, não faz nada.)

```abap
FORM f_modify USING f_carr TYPE tp_carr.
  UPDATE scarr
  SET carrname = @f_carr-vtp_cname,
      url      = @f_carr-vtp_url
  WHERE carrid = @f_carr-vtp_cid.
  PERFORM f_command_status USING sy-subrc.
ENDFORM.
```

```abap
  PARAMETERS: v_csid   TYPE scustom-id OBLIGATORY,   "Código do Passageiro
            v_csmail TYPE scustom-email OBLIGATORY.  "Novo Email
            
  UPDATE scustom 
  SET email = @v_csmail 
  WHERE id = @v_csid.
  
  IF sy-subrc = 0.
    WRITE: / |ID { v_csid } teve seu email alterado para { v_csmail }.|.
  ELSE.
    MESSAGE e012(z08). "Erro ao atualizar o email
  ENDIF.
```

## DELETE

Deletar dados de uma tabela.

```abap
FORM f_delete USING f_carr TYPE tp_carr.
  DELETE FROM scarr
  WHERE carrid = f_carr-vtp_cid.
  PERFORM f_command_status USING sy-subrc.
ENDFORM.
```

## TABELA INTERNA

Alterando (várias) linhas de uma tabela interna.

```abap
LOOP AT t_passageiro ASSIGNING FIELD-SYMBOL(<pass>). " FIELD-SYMBOL é um PONTEIRO
  IF <pass>-langu = 'P'.
    <pass>-country = 'BR'.
  ENDIF.
ENDLOOP.
```

```abap
DATA: it_copy_sflight  TYPE TABLE OF sflight,
      it_valid_sflight TYPE TABLE OF sflight.

SELECT *
  FROM sflight
  INTO TABLE @it_copy_sflight
  WHERE carrid IN @v_cid
    AND fldate IN @v_fldt.

LOOP AT it_copy_sflight ASSIGNING FIELD-SYMBOL(<it_line>).
  IF ( <it_line>-seatsmax * '0.6' ) > <it_line>-seatsocc.
    <it_line>-price =  <it_line>-price * '1.15'.
    APPEND <it_line> TO it_valid_sflight.
  ENDIF.
ENDLOOP.

MODIFY sflight FROM TABLE it_valid_sflight.
```

Excluindo linhas da tabela interna.

```abap
LOOP AT t_passageiro ASSIGNING FIELD-SYMBOL(<pass>).
  IF <pass>-langu = 'D'.
    DELETE t_passageiro.
  ENDIF.
ENDLOOP.

" O loop acima poderia ser escrito como:
DELETE t_passageiro WHERE langu = 'D'.
```

Imprimindo itens de uma tabela interna usando Work-Area

```abap
  TYPES: BEGIN OF tp_custom,
           vtp_scustom_ID   TYPE scustom-id,
           vtp_scustom_name TYPE scustom-name,
           vtp_scustom_city TYPE scustom-city,
         END OF tp_custom.

FORM f_search_data_1. " Usando Work-Area (EVITAR, INEFICIENTE)
  DATA: it_scustom TYPE TABLE OF tp_custom,
        wa_scustom TYPE tp_custom.

  SELECT id, name, city
    FROM scustom
    INTO TABLE @it_scustom
    WHERE id IN @v_cid.
  PERFORM f_command_status USING sy-subrc.

  LOOP AT it_scustom INTO wa_scustom.
    WRITE: / 'ID:', wa_scustom-vtp_scustom_id, ' | ',
             'Nome:', wa_scustom-vtp_scustom_name, ' | ',
             'Cidade:', wa_scustom-vtp_scustom_city.
  ENDLOOP.
ENDFORM.
```

Imprimindo itens de uma tabela interna usando Linha de Cabeçalho

```abap
FORM f_search_data_2. " Usando Linha de Cabeçalho (NUNCA USAR, GERA AMBIGUIDADE)
  DATA: it_scustom TYPE TABLE OF tp_custom WITH HEADER LINE.

  SELECT id, name, city
    FROM scustom
    INTO TABLE @it_scustom
    WHERE id IN @v_cid.
  PERFORM f_command_status USING sy-subrc.

  LOOP AT it_scustom.
    WRITE: / 'ID:', it_scustom-vtp_scustom_ID, ' | ',
             'Nome:', it_scustom-vtp_scustom_name, ' | ',
             'Cidade:', it_scustom-vtp_scustom_city.
  ENDLOOP.
ENDFORM.
```

Imprimindo itens de uma tabela interna usando Field-Symbol

```abap
FORM f_search_data_3. " Usando Field-Symbol (RECOMENDADO USAR, MAIS EFICIENTE)
  DATA: it_scustom TYPE TABLE OF tp_custom.
  FIELD-SYMBOLS: <fs_line> LIKE LINE OF it_scustom.

  SELECT id, name, city
  FROM scustom
  INTO TABLE @it_scustom
  WHERE id IN @v_cid.
  PERFORM f_command_status USING sy-subrc.

  LOOP AT it_scustom ASSIGNING <fs_line>.
    WRITE: / 'ID:', <fs_line>-vtp_scustom_id, ' | ',
             'Nome:', <fs_line>-vtp_scustom_name, ' | ',
             'Cidade:', <fs_line>-vtp_scustom_city.
  ENDLOOP.
ENDFORM.
```

```abap
  TYPES: t_tp_sflight TYPE TABLE OF sflight.
FORM f_print_table USING f_table TYPE t_tp_sflight.
  FIELD-SYMBOLS: <f_line> LIKE LINE OF f_table.
  LOOP AT f_table ASSIGNING <f_line>.
    WRITE: / <f_line>-carrid,
    <f_line>-connid,
    <f_line>-fldate,
    <f_line>-price,
    <f_line>-seatsmax,
    <f_line>-seatsocc.
  ENDLOOP.
ENDFORM.
```

---

```abap
REPORT z_selects_type.

* Declarações
DATA :
  it_spfli   TYPE TABLE OF spfli,
  it_sflight TYPE TABLE OF sflight,
  st_spfli   TYPE spfli,
  st_sflight TYPE sflight
  .

* Select simples.
PERFORM f_simples.

* select com condição.
PERFORM f_condicao.

* Seleciona somente uma linha
PERFORM f_single.

*  Seleciona somente as informações de um ou mais campos alimenta
* uma ou mais variáveis conforme condições.
PERFORM f_variavel.

*  Selecionando campos especificos e alimentando os respectivo
* campos da tabela/ estrutura.
PERFORM f_corresponding_fields.

*  Seleciona conforme informações específicas ( MAX, MIN, AVG, SUM, COUNT )
PERFORM f_agregados.


*&---------------------------------------------------------------------*
*&      Form  f_simples
*&---------------------------------------------------------------------*
FORM f_simples .

* Selecionou tudo da tabela SPFLI e colocou tudo numa tabela interna.
  SELECT *
    FROM spfli
    INTO TABLE it_spfli.

  BREAK-POINT.

  FREE it_spfli.

ENDFORM.                    " f_simples

*&---------------------------------------------------------------------*
*&      Form  f_condicao
*&---------------------------------------------------------------------*
FORM f_condicao .

* Selecionou somente os registros que se adequam a condição ( Carrid = AA e
* connid = '0064') da tabela transaparente SPFLI e colocou os registros
* dentro da tabela interna IT_SPFLI.
  SELECT *
    FROM spfli
    INTO TABLE it_spfli
    WHERE carrid = 'AA'
      AND connid = '0064'.

  BREAK-POINT.

  FREE it_spfli.


ENDFORM.                    " f_condicao

*&---------------------------------------------------------------------*
*&      Form  f_single
*&---------------------------------------------------------------------*
FORM f_single .

* Selecionou somente um registro (conforme condição)e jogou para uma
* estrutura.
  SELECT SINGLE *
    FROM spfli
    INTO st_spfli
    WHERE carrid = 'AA'
    .

  "  Obs. Caso todas as condições sejam chave da tabela, não será necessário
  " o uso do comando 'SINGLE' pois sempre retornará um registro.
  BREAK-POINT.

  CLEAR st_spfli.


ENDFORM.                    " f_single
*&---------------------------------------------------------------------*
*&      Form  f_variavel
*&---------------------------------------------------------------------*
FORM f_variavel .

  DATA :
    vl_cityfrom TYPE spfli-cityfrom,
    vl_cityto   TYPE spfli-cityto.

* Com uma variável
  SELECT SINGLE cityfrom
    FROM spfli
    INTO vl_cityfrom
    WHERE carrid = 'AA'.

  BREAK-POINT.

  CLEAR vl_cityfrom.

* Com mais variáveis
  SELECT SINGLE cityfrom cityto
    FROM spfli
    INTO (vl_cityfrom, vl_cityto)
    WHERE carrid = 'AA'.

  BREAK-POINT.

  CLEAR : vl_cityfrom , vl_cityto.


ENDFORM.                    " f_variavel

*&---------------------------------------------------------------------*
*&      Form  f_corresponding_fields
*&---------------------------------------------------------------------*
FORM f_corresponding_fields .

* Alimentando tabela
  SELECT carrid connid cityfrom cityto
    FROM spfli
    INTO CORRESPONDING FIELDS OF TABLE it_spfli
    .
  BREAK-POINT.
  FREE it_spfli.

* Alimentando estrutura
  SELECT SINGLE carrid connid cityfrom cityto
    FROM spfli
    INTO CORRESPONDING FIELDS OF st_spfli
    .
  BREAK-POINT.
  CLEAR st_spfli.


ENDFORM.                    " f_corresponding_fields

*&---------------------------------------------------------------------*
*&      Form  f_agregados
*&---------------------------------------------------------------------*
FORM f_agregados .

  DATA :
    vl_value TYPE i.

* Valor máximo para o campos determinado
  SELECT MAX( fltime )
    FROM spfli
    INTO vl_value.
  BREAK-POINT.
  CLEAR st_spfli.

* Valor Minimo para o campos determinado
  SELECT MIN( fltime )
    FROM spfli
    INTO vl_value.
  BREAK-POINT.
  CLEAR st_spfli.

*  Valor medio entre todos os registro ( com condição ) para
* campo determinado
  SELECT AVG( fltime )
    FROM spfli
    INTO vl_value
    WHERE carrid = 'AA'.
  BREAK-POINT.
  CLEAR st_spfli.

*  Soma entre todos os registro ( com condição ) para o campo
* determinado
  SELECT SUM( fltime )
    FROM spfli
    INTO vl_value
    WHERE carrid = 'JL'.
  BREAK-POINT.
  CLEAR st_spfli.

* Informa a quantidade de registro existentes
  SELECT COUNT( * )
    FROM spfli
    INTO vl_value.
  BREAK-POINT.
  CLEAR st_spfli.

ENDFORM.                    " f_agregados
```