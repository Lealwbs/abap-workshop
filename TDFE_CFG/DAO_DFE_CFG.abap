CLASS /s4tax/dao_dfe_cfg DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPE-POOLS: abap.
    INTERFACES /s4tax/idao_dfe_cfg.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /s4tax/dao_dfe_cfg IMPLEMENTATION.
  METHOD /s4tax/idao_dfe_cfg~delete.
    IF start_operation IS INITIAL.
      RETURN.
    ENDIF.

    DELETE FROM /s4tax/tdfe_cfg WHERE start_operation = start_operation.
  ENDMETHOD.

  METHOD /s4tax/idao_dfe_cfg~get_first.
    DATA: dfe_cfg TYPE /s4tax/tdfe_cfg_t,
          dfe_cfg_first_obj TYPE REF TO /s4tax/document_config.

    SELECT * FROM /s4tax/tdfe_cfg INTO TABLE dfe_cfg UP TO 1 ROWS.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CREATE OBJECT dfe_cfg_first_obj EXPORTING iw_struct = dfe_cfg[ 1 ].

    result = dfe_cfg_first_obj.
  ENDMETHOD.

  METHOD /s4tax/idao_dfe_cfg~get_all.
    DATA: dfe_cfg TYPE /s4tax/tdfe_cfg_t.

    SELECT * FROM /s4tax/tdfe_cfg INTO TABLE dfe_cfg.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    result = me->/s4tax/idao_dfe_cfg~struct_to_objects( dfe_cfg_table =  dfe_cfg ).
  ENDMETHOD.

  METHOD /s4tax/idao_dfe_cfg~get_by_start_operation.
    DATA: dfe_cfg TYPE /s4tax/tdfe_cfg.

    SELECT SINGLE * FROM /s4tax/tdfe_cfg
    INTO dfe_cfg
    WHERE start_operation EQ start_operation.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CREATE OBJECT result EXPORTING iw_struct = dfe_cfg.
  ENDMETHOD.


  METHOD /s4tax/idao_dfe_cfg~save.
    DATA: dfe_config TYPE /s4tax/tdfe_cfg.

    IF dfe_cfg IS NOT BOUND.
      RETURN.
    ENDIF.

    dfe_config-start_operation = dfe_cfg->get_start_operation( ).
    dfe_config-job_ex_type = dfe_cfg->get_job_ex_type( ).
    dfe_config-status_update_time = dfe_cfg->get_status_update_time( ).
    dfe_config-grc_destination = dfe_cfg->get_grc_destination( ).
    dfe_config-source_text = dfe_cfg->get_source_text( ).
    dfe_config-save_xml = dfe_cfg->get_save_xml( ).

    MODIFY /s4tax/tdfe_cfg FROM dfe_config.

  ENDMETHOD.

  METHOD /s4tax/idao_dfe_cfg~save_many.
    DATA: dfe_cfg_table TYPE /s4tax/tdfe_cfg_t.

    IF dfe_cfg_list IS INITIAL.
      RETURN.
    ENDIF.

    dfe_cfg_table = me->/s4tax/idao_dfe_cfg~objects_to_struct( dfe_cfg_list ).

    MODIFY /s4tax/tdfe_cfg FROM TABLE dfe_cfg_table.

  ENDMETHOD.

  METHOD /s4tax/idao_dfe_cfg~objects_to_struct.
    DATA: dfe_cnfg TYPE REF TO /s4tax/document_config.

    IF dfe_cfg_list IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT dfe_cfg_list INTO dfe_cnfg.
      IF dfe_cnfg IS NOT BOUND.
        CONTINUE.
      ENDIF.
      APPEND dfe_cnfg->struct TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD /s4tax/idao_dfe_cfg~struct_to_objects.
    DATA: dfe_cfg  TYPE /s4tax/tdfe_cfg,
          dfe_cnfg TYPE REF TO /s4tax/document_config.

    IF dfe_cfg_table IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT dfe_cfg_table INTO dfe_cfg.
      CREATE OBJECT dfe_cnfg EXPORTING iw_struct = dfe_cfg.
      APPEND dfe_cnfg TO result.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.