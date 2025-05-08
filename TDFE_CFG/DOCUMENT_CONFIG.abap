CLASS /s4tax/document_config DEFINITION
  PUBLIC
  INHERITING FROM /s4tax/model_dfe_cfg
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING iw_struct TYPE /s4tax/tdfe_cfg OPTIONAL.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /s4tax/document_config IMPLEMENTATION.
  METHOD constructor.

    super->constructor( ).

    IF iw_struct IS INITIAL.
      RETURN.
    ENDIF.

    me->set_start_operation( start_op = iw_struct-start_operation ).
    me->set_job_ex_type( type = iw_struct-job_ex_type ).
    me->set_status_update_time( iw_struct-status_update_time ).

  ENDMETHOD.

ENDCLASS.