INTERFACE /s4tax/idao_dfe_cfg
  PUBLIC .
  METHODS:

    delete IMPORTING start_operation TYPE /s4tax/e_start_operation,

    get_first RETURNING VALUE(result) TYPE REF TO /s4tax/document_config,

    get_all RETURNING VALUE(result) TYPE /s4tax/document_config_t,

    get_by_start_operation IMPORTING start_operation TYPE /s4tax/e_start_operation
                           RETURNING VALUE(result)   TYPE REF TO /s4tax/document_config,

    save IMPORTING dfe_cfg TYPE REF TO /s4tax/document_config,

    save_many IMPORTING dfe_cfg_list TYPE /s4tax/document_config_t,

    struct_to_objects IMPORTING dfe_cfg_table TYPE /s4tax/tdfe_cfg_t
                      RETURNING VALUE(result) TYPE /s4tax/document_config_t,

    objects_to_struct IMPORTING dfe_cfg_list  TYPE /s4tax/document_config_t
                      RETURNING VALUE(result) TYPE /s4tax/tdfe_cfg_t.
ENDINTERFACE.