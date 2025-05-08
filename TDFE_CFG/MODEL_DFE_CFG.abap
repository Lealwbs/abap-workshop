CLASS /s4tax/model_dfe_cfg DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA: struct TYPE /s4tax/tdfe_cfg READ-ONLY.
    METHODS:
      get_start_operation RETURNING VALUE(result) TYPE /s4tax/tdfe_cfg-start_operation,
      set_start_operation IMPORTING iv_start_operation TYPE /s4tax/tdfe_cfg-start_operation,
      get_job_ex_type RETURNING VALUE(result) TYPE /s4tax/tdfe_cfg-job_ex_type,
      set_job_ex_type IMPORTING iv_job_ex_type TYPE /s4tax/tdfe_cfg-job_ex_type,
      get_status_update_time RETURNING VALUE(result) TYPE /s4tax/tdfe_cfg-status_update_time,
      set_status_update_time IMPORTING iv_status_update_time TYPE /s4tax/tdfe_cfg-status_update_time,
      get_grc_destination RETURNING VALUE(result) TYPE /s4tax/tdfe_cfg-grc_destination,
      set_grc_destination IMPORTING iv_grc_destination TYPE /s4tax/tdfe_cfg-grc_destination,
      get_save_xml RETURNING VALUE(result) TYPE /s4tax/tdfe_cfg-save_xml,
      set_save_xml IMPORTING iv_save_xml TYPE /s4tax/tdfe_cfg-save_xml,
      get_source_text RETURNING VALUE(result) TYPE /s4tax/tdfe_cfg-source_text,
      set_source_text IMPORTING iv_source_text TYPE /s4tax/tdfe_cfg-source_text.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS /s4tax/model_dfe_cfg IMPLEMENTATION.

  METHOD get_start_operation.
    result = me->struct-start_operation.
  ENDMETHOD.

  METHOD set_start_operation.
    me->struct-start_operation = iv_start_operation.
  ENDMETHOD.

  METHOD get_job_ex_type.
    result = me->struct-job_ex_type.
  ENDMETHOD.

  METHOD set_job_ex_type.
    me->struct-job_ex_type = iv_job_ex_type.
  ENDMETHOD.

  METHOD get_status_update_time.
    result = me->struct-status_update_time.
  ENDMETHOD.

  METHOD set_status_update_time.
    me->struct-status_update_time = iv_status_update_time.
  ENDMETHOD.

  METHOD get_grc_destination.
    result = me->struct-grc_destination.
  ENDMETHOD.

  METHOD set_grc_destination.
    me->struct-grc_destination = iv_grc_destination.
  ENDMETHOD.

  METHOD get_save_xml.
    result = me->struct-save_xml.
  ENDMETHOD.

  METHOD set_save_xml.
    me->struct-save_xml = iv_save_xml.
  ENDMETHOD.

  METHOD get_source_text.
    result = me->struct-source_text.
  ENDMETHOD.

  METHOD set_source_text.
    me->struct-source_text = iv_source_text.
  ENDMETHOD.

ENDCLASS.