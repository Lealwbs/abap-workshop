CLASS zis_api_partner DEFINITION
  PUBLIC
  INHERITING FROM /s4tax/api_signed_service
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES: zis_iapi_partner.

    CONSTANTS:
      get_partner_by_id TYPE string VALUE '/partner-service/api/partners/:partnerId'.

    CLASS-DATA: instance TYPE REF TO zis_iapi_partner.

    CLASS-METHODS:
      get_instance
        IMPORTING api_auth      TYPE REF TO /s4tax/iapi_auth OPTIONAL
        RETURNING VALUE(result_instance) TYPE REF TO zis_iapi_partner
        RAISING   /s4tax/cx_http /s4tax/cx_autH.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zis_api_partner IMPLEMENTATION.

  METHOD get_instance.
    DATA: session           TYPE REF TO /s4tax/session,
          api_authorization TYPE REF TO /s4tax/iapi_auth.

    IF instance IS BOUND.
      result_instance = instance.
      RETURN.
    ENDIF.

    api_authorization = api_auth.
    IF api_authorization IS NOT BOUND.
      api_authorization = /s4tax/api_auth=>default_instance( ).
    ENDIF.

    session = api_authorization->login( /s4tax/defaults=>customer_profile_name ).
    CREATE OBJECT instance TYPE zis_api_partner EXPORTING session = session.
    result_instance = instance.

  ENDMETHOD.

  METHOD zis_iapi_partner~search_partner.

    DATA: path_parameter   TYPE /s4tax/api_service=>path_parameter,
          path_parameters  TYPE path_parameter_t,
          context_id       TYPE /s4tax/trequest-context_id,
          request_dto      TYPE REF TO /s4tax/request,
          json_config      TYPE REF TO /s4tax/json_element_config,
          config_generator TYPE REF TO /s4tax/json_config_generator.

    context_id = partner_id.

    path_parameter-name     = ':partnerId'.
    path_parameter-value    = partner_id.

    APPEND path_parameter TO path_parameters.

    request_dto = create_custom_request_dto( context    = /s4tax/constants=>context-part
                                             context_Id = context_id
                                             ).

    create_request_obj_with_param( EXPORTING session     = me->session
                                             http_path   = get_partner_by_id
                                             http_method = /s4tax/http_operation=>http_methods-get
                                             request_dto = request_dto
                                             path_params = path_parameters
                                   CHANGING  output      = result
                                             request     = last_request ).


    CREATE OBJECT config_generator EXPORTING name_to_camel = abap_false.
    json_config = config_generator->generate_data_type_config( result ).
    last_request->add_prop( EXPORTING name = /s4tax/http_request=>commom_props_name-response_element_config
                                      obj  = json_config ).

    last_request->send( ).

  ENDMETHOD.

ENDCLASS.