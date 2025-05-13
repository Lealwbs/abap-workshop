CLASS /s4tax/t_dfe_cfg DEFINITION
  PUBLIC
  INHERITING FROM /s4tax/task
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPE-POOLS abap.
    METHODS: constructor  IMPORTING version        TYPE string DEFAULT '1.0'
                                    repeatable     TYPE abap_bool DEFAULT abap_false
                                    priority       TYPE i OPTIONAL
                                    idao_pack_core TYPE REF TO /s4tax/idao OPTIONAL
                                    dao_dfe_cfg    TYPE REF TO /s4tax/idao_dfe_cfg OPTIONAL,

      get_information REDEFINITION.

  PROTECTED SECTION.
    METHODS: apply REDEFINITION.

  PRIVATE SECTION.
    DATA: dao_dfe_cfg    TYPE REF TO /s4tax/idao_dfe_cfg,
          idao_pack_core TYPE REF TO /s4tax/idao.

    METHODS: apply_jobs.
ENDCLASS.



CLASS /s4tax/t_dfe_cfg IMPLEMENTATION.
  METHOD apply.
    DATA: dfe_cfg     TYPE REF TO /s4tax/document_config.

    apply_jobs(  ).

    CREATE OBJECT dfe_cfg.
    dfe_cfg->set_start_operation( sy-datum ).
    dfe_cfg->set_job_ex_type( /s4tax/dfe_constants=>job_ex_type-recurring_job ).
    dfe_cfg->set_status_update_time( '000500'  ).
    dfe_cfg->set_source_text( iv_source_text = '1' ).
    dfe_cfg->set_save_xml( iv_save_xml = 'X' ).

    dao_dfe_cfg->save( dfe_cfg ).
  ENDMETHOD.

  METHOD constructor.
    super->constructor(  version = version  repeatable = repeatable
                         priority = priority ).

    me->dao_dfe_cfg = dao_dfe_cfg.
    IF me->dao_dfe_cfg IS INITIAL.
      CREATE OBJECT me->dao_dfe_cfg TYPE /s4tax/dao_dfe_cfg.
    ENDIF.

    me->idao_pack_core = idao_pack_core.
    IF idao_pack_core IS NOT BOUND.
      me->idao_pack_core = /s4tax/dao=>default_instance( ).
    ENDIF.
  ENDMETHOD.

  METHOD apply_jobs.

    DATA: job      TYPE REF TO /s4tax/job,
          job_list TYPE /s4tax/job_t,
          dao_job  TYPE REF TO /s4tax/idao_job.

    CREATE OBJECT: job.
    job->set_job_prog( '/S4TAX/DFE_CHECK_STATUS' ).
    job->set_required( 'X' ).
    job->set_suggested_time( '1' ).
    APPEND job TO job_list.

    CREATE OBJECT: job.
    job->set_job_prog( '/S4TAX/DFE_EVENT_CHECK_STATUS' ).
    job->set_required( 'X' ).
    job->set_suggested_time( '1' ).
    APPEND job TO job_list.

    CREATE OBJECT: job.
    job->set_job_prog( '/S4TAX/DFE_INUTILIZACAO_STATUS' ).
    job->set_required( 'X' ).
    job->set_suggested_time( '1' ).
    APPEND job TO job_list.

    CREATE OBJECT: job.
    job->set_job_prog( '/S4TAX/SEND_CONFIGURATIONS' ).
    job->set_required( '' ).
    job->set_suggested_time( '43200' ).
    APPEND job TO job_list.

    CREATE OBJECT: job.
    job->set_job_prog( '/S4TAX/GARBAGE_COLLECTOR' ).
    job->set_required( '' ).
    job->set_suggested_time( '1440' ).
    APPEND job TO job_list.

    CREATE OBJECT: job.
    job->set_job_prog( '/S4TAX/DFE_SEND_EMAIL' ).
    job->set_required( '' ).
    job->set_suggested_time( '1440' ).
    APPEND job TO job_list.

    dao_job = me->idao_pack_core->job(  ).
    dao_job->save_many( job_list ).

  ENDMETHOD.

  METHOD get_information.
    DATA: information TYPE string.

    information = 'Refere-se à classe /s4tax/t_dfe_cfg.'.
    APPEND information TO result.

    information = 'Preenche a tabela /s4tax/job com jobs de DFE.'.
    APPEND information TO result.

    information = 'Preenche a tabela /s4tax/tdfe_cfg com configurações gerais de DFE.'.
    APPEND information TO result.
  ENDMETHOD.

ENDCLASS.