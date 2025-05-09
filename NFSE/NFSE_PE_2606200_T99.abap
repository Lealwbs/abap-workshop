**&---------------------------------------------------------------------*
**& Include /s4tax/nfse_pe2607901_t99
**&---------------------------------------------------------------------*
*CLASS ltcl_nfse_pe2607901 DEFINITION FINAL FOR TESTING
*INHERITING FROM /s4tax/nfse_default_test
*  DURATION SHORT
*  RISK LEVEL HARMLESS.
*
*  PRIVATE SECTION.
*    DATA: cut TYPE REF TO /s4tax/nfse_pe2607901.
*    METHODS:
*      setup,
*      get_identificacao FOR TESTING RAISING cx_static_check,
*      get_reason_cancel FOR TESTING RAISING cx_static_check.
*ENDCLASS.
*
*
*CLASS ltcl_nfse_pe2607901 IMPLEMENTATION.
*
*  METHOD setup.
*    DATA: cx_root    TYPE REF TO cx_root,
*          class_name TYPE seoclname.
*    TRY.
*        class_name = /s4tax/tests_utils=>get_classname_by_data( cut ).
*        me->branch_info->get_class( )->set_class( class_name ).
*        cut ?= /s4tax/nfse_default=>get_instance( branch_info = me->branch_info documents = me->documents reporter = reporter ).
*      CATCH cx_root INTO cx_root.
*    ENDTRY.
*  ENDMETHOD.
*
*  METHOD get_identificacao.
*    DATA: expected      TYPE /s4tax/s_nfse_identificacao,
*          identificacao TYPE /s4tax/s_nfse_identificacao.
*
*    expected = mount_identificacao_expected( ).
*    expected-regime_especial_tributacao = '1'.
*    expected-competencia = '2021-02-03'.
*
*    me->mock_identificacao( ).
*    me->mock_extension( ).
*
*    identificacao = cut->get_rps_identificacao( ).
*    cl_abap_unit_assert=>assert_equals( exp = expected-competencia
*                                        act = identificacao-competencia ).
*
*    cl_abap_unit_assert=>assert_equals( exp = expected-regime_especial_tributacao
*                                        act = identificacao-regime_especial_tributacao ).
*
*    me->extension_head->set_reg_espec_tribut( 'M' ).
*    expected-regime_especial_tributacao = '5'.
*    identificacao = cut->get_rps_identificacao( ).
*    cl_abap_unit_assert=>assert_equals( exp = expected-regime_especial_tributacao
*                                        act = identificacao-regime_especial_tributacao ).
*  ENDMETHOD.
*
*  METHOD get_reason_cancel.
*    DATA: reason TYPE /s4tax/s_nfse_cancel_fields,
*          expected TYPE /s4tax/s_nfse_cancel_fields.
*
*    expected-code = '2'.
*
*    reason = cut->/s4tax/infse_data~get_reasons_cancellation( '' ).
*    cl_abap_unit_assert=>assert_equals( act = 'Servico nao prestado' exp = reason-motivo ).
*    cl_abap_unit_assert=>assert_equals( act = expected-code exp = reason-code ).
*  ENDMETHOD.
*
*ENDCLASS.