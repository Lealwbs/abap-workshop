*&---------------------------------------------------------------------*
*& Report Z08_EXERC8_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc8_1.

TYPES: BEGIN OF tp_car_idntf,
         vtp_marca  TYPE string,
         vtp_modelo TYPE string,
         vtp_cor    TYPE string,
       END OF tp_car_idntf.

CLASS cl_carro DEFINITION.
  PUBLIC SECTION.
    METHODS: constructor
      IMPORTING marca          TYPE string
                modelo         TYPE string
                cor            TYPE string
                kilometragem   TYPE i      DEFAULT 0
                ultima_revisao TYPE i      DEFAULT 0.

    METHODS:
  set_ultima_revisao IMPORTING dt_ultima_revisao TYPE i,
  atualiza_km        IMPORTING novo_km           TYPE i,
  get_ultima_revisao EXPORTING dt_ultima_revisao TYPE i,
  get_identificacao  RETURNING VALUE(car_idntf)  TYPE tp_car_idntf,
  get_km             RETURNING VALUE(km)         TYPE i,
  verify_revisao     IMPORTING range_rev         TYPE i
                     RETURNING VALUE(ating_rev)  TYPE char1.

  PRIVATE SECTION.
    DATA: marca          TYPE string,
          modelo         TYPE string,
          cor            TYPE string,
          kilometragem   TYPE i,
          ultima_revisao TYPE i.

ENDCLASS.

CLASS cl_carro IMPLEMENTATION.
  METHOD constructor.
    me->marca          = marca.
    me->modelo         = modelo.
    me->cor            = cor.
    me->kilometragem   = kilometragem.
    me->ultima_revisao = ultima_revisao.
  ENDMETHOD.

  METHOD set_ultima_revisao.
    me->ultima_revisao = dt_ultima_revisao.
  ENDMETHOD.

  METHOD atualiza_km.
    me->kilometragem = novo_km.
  ENDMETHOD.

  METHOD get_ultima_revisao .
    dt_ultima_revisao = me->ultima_revisao.
  ENDMETHOD.

  METHOD get_identificacao.
    car_idntf-vtp_marca  = me->marca.
    car_idntf-vtp_modelo = me->modelo.
    car_idntf-vtp_cor    = me->cor.
    RETURN: car_idntf.
  ENDMETHOD.

  METHOD get_km.
    RETURN me->kilometragem.
  ENDMETHOD.

  METHOD verify_revisao.
    IF ( me->ultima_revisao + range_rev ) < me->kilometragem.
     ating_rev = 'X'.
    ELSE.
     ating_rev = ' '.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

SELECTION-SCREEN BEGIN OF BLOCK b_input WITH FRAME TITLE TEXT-001.
  PARAMETERS: v_novokm TYPE I OBLIGATORY,
              v_rngrev TYPE I OBLIGATORY DEFAULT 0.
SELECTION-SCREEN END OF BLOCK b_input.

AT SELECTION-SCREEN.
IF v_novokm < 0 OR v_rngrev < 0.
  MESSAGE e025(z08). "Digite apenas valores positivos.
ENDIF.

IF v_rngrev > v_novokm.
  MESSAGE e024(z08). "A kilometragem da última revisão não pode ser maior que a nova kilom.
ENDIF.

START-OF-SELECTION.

DATA(c1) = NEW cl_carro( marca          = 'Fiat'
                         modelo         = 'Uno'
                         cor            = 'Vermelho'
                         kilometragem   = 102500
                         ultima_revisao = 100000 ).

DATA(c2) = NEW cl_carro( marca          = 'Renault'
                         modelo         = 'Kwid'
                         cor            = 'Branco'
                         kilometragem   = 156000
                         ultima_revisao = 150000 ).


DATA: v_ultima_revisao TYPE i.
c1->get_ultima_revisao( IMPORTING dt_ultima_revisao = v_ultima_revisao ).

WRITE: / |{ c1->get_identificacao( )-vtp_marca  }|,
         |{ c1->get_identificacao( )-vtp_modelo }|,
         |{ c1->get_identificacao( )-vtp_cor    }|,
       / |Hodômetro: { c1->get_km( ) }km|,
       / |Última Revisão: { v_ultima_revisao }km|.

ULINE.

c1->atualiza_km( v_novokm ).
c2->atualiza_km( v_novokm ).

DATA: c1_bool_vrev,
      c2_bool_vrev.

c1_bool_vrev = c1->verify_revisao( v_rngrev ).
c2_bool_vrev = c2->verify_revisao( v_rngrev ).

PERFORM f_write_verify_revisao USING c1_bool_vrev.
PERFORM f_write_verify_revisao USING c2_bool_vrev.

END-OF-SELECTION.

FORM f_write_verify_revisao USING bool TYPE char1.
  IF bool = 'X'.
    WRITE: / |ATENÇÃO: O carro atingiu a kilometragem da próxima revisão.|.
  ELSE.
    WRITE: / |O carro ainda NÃO atingiu a kilom. da próxima revisão.|.
  ENDIF.
ENDFORM.