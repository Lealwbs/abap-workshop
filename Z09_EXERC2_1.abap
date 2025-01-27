*&---------------------------------------------------------------------*
*& Report Z08_EXERC2_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc2_1.

SELECTION-SCREEN BEGIN OF BLOCK b_query WITH FRAME TITLE TEXT-001.
  PARAMETERS: v_idclnt TYPE i OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b_query.

AT SELECTION-SCREEN.

  IF v_idclnt < 1.
    MESSAGE e008(z08).
  ENDIF.

START-OF-SELECTION.

  TYPES: BEGIN OF s_user,
           nome   TYPE c LENGTH 20,
           cidade TYPE c LENGTH 20,
           idioma TYPE c LENGTH 1,
         END OF s_user.


  DATA: v_utmp TYPE s_user.

  SELECT SINGLE name, city, langu
        FROM scustom
        INTO @v_utmp
        WHERE id = @v_idclnt.

END-OF-SELECTION.

  IF sy-subrc = 0. " Se sy-subrc=0: QuerySem erros
    WRITE: / |Nome: { v_utmp-nome } |,
           / |Cidade: { v_utmp-cidade }|,
           / |Idioma: { v_utmp-idioma } |.
  ELSE.
    WRITE: |Cliente { v_idclnt } não encontrado.|.
  ENDIF.

* O valor listado pelo meu programa é diferente do listado na tabela SCUSTOM pois
* meu programa não efetua uma rotina de conversão no idioma, enquanto a tabela já executa.
* Ou seja, em meu programa o Idioma sairia como "E" ao invés de "EN" ou "Inglês".