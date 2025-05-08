CLASS /s4tax/model_dfe_cfg DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA: struct TYPE /s4tax/tdfe_cfg READ-ONLY.
    METHODS: get_start_operation RETURNING VALUE(result) TYPE /s4tax/e_start_operation,
      set_start_operation IMPORTING start_op TYPE /s4tax/e_start_operation,
      get_job_ex_type RETURNING VALUE(result) TYPE /s4tax/e_dfe_job_cfg,
      set_job_ex_type IMPORTING type TYPE /s4tax/e_dfe_job_cfg,
      get_status_update_time RETURNING VALUE(result) TYPE /s4tax/tdfe_cfg-status_update_time,
      set_status_update_time IMPORTING iv_status_update_time TYPE /s4tax/tdfe_cfg-status_update_time.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /s4tax/model_dfe_cfg IMPLEMENTATION.

  METHOD get_start_operation.
    result = me->struct-start_operation.
  ENDMETHOD.

  METHOD set_start_operation.
    me->struct-start_operation = start_op.
  ENDMETHOD.

  METHOD get_job_ex_type.
    result = me->struct-job_ex_type.
  ENDMETHOD.

  METHOD set_job_ex_type.
    me->struct-job_ex_type = type.
  ENDMETHOD.

  METHOD get_status_update_time.
    result = me->struct-status_update_time.
  ENDMETHOD.

  METHOD set_status_update_time.
    me->struct-status_update_time = iv_status_update_time.
  ENDMETHOD.

ENDCLASS.