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
    MESSAGE e008(z08). "ID inválido, digite um ID positivo válido.
  ENDIF.

START-OF-SELECTION.

  TYPES: BEGIN OF s_user,
           nome   TYPE scustom-name,
           cidade TYPE scustom-city,
           idioma TYPE scustom-langu,
         END OF s_user.

  DATA: v_utmp TYPE s_user.

END-OF-SELECTION.

  SELECT SINGLE name city langu
        FROM scustom
        INTO v_utmp
        WHERE id = v_idclnt.
  IF sy-subrc = 0. " Se sy-subrc=0: QuerySem erros
    WRITE: / |Nome: { v_utmp-nome } |,
           / |Cidade: { v_utmp-cidade }|,
           " / |Idioma: { v_utmp-idioma }|. * Retorna incorretamente o resultado de v_utmp-idioma
           / |Idioma:|, v_utmp-idioma.
  ELSE.
    WRITE: |Cliente { v_idclnt } não encontrado.|.
  ENDIF.

* O valor v_utmp-idioma quando impresso entre |v_utmp-idioma| mostra apenas 1 letra,
* mas quando é usado como argumento seperado da função WRITE:, ele mostra 2 letras normalmente.