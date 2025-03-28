*"* use this source file for your ABAP unit test classes
CLASS ltcl_zis_api_partner DEFINITION FINAL FOR TESTING
  INHERITING FROM /s4tax/api_signed_test
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    DATA: cut TYPE REF TO zis_api_partner.

    METHODS:
      setup,
      get_partner_by_id FOR TESTING,
      error_get_partner_by_id FOR TESTING.

ENDCLASS.


CLASS ltcl_zis_api_partner IMPLEMENTATION.

  METHOD setup.

    DATA: defaults TYPE REF TO /s4tax/defaults.
    mount_data(  ).

    TRY.
        mock_configuration(  ).
        defaults = NEW #( mock_dao_pack ).
        cut = NEW #( session = session defaults = defaults ).
      CATCH /s4tax/cx_auth /s4tax/cx_http.
    ENDTRY.

  ENDMETHOD.


  METHOD get_partner_by_id.
    DATA: output          TYPE /s4tax/s_search_partner_o,
          expected_output TYPE /s4tax/s_search_partner_o,
          partner_id      TYPE string,
          status_code     TYPE i.

    partner_id = '172c4ad5-8924-44e1-a726-7b484d20e7f2'.

    DATA(valid_response) = '{' &&
                           '  "data": {' &&
                           '    "partner": {' &&
                           '      "id": "172c4ad5-8924-44e1-a726-7b484d20e7f2",' &&
                           '      "name": "John Doe LTDA",' &&
                           '      "fantasy_name": "John Doe LTDA",' &&
                           '      "birth_date": "2012-04-23T18:25:43.511Z",' &&
                           '      "partner_type": "PJ",' &&
                           '      "created_at": "2023-07-18T21:40:24.058Z",' &&
                           '      "updated_at": "2023-07-18T21:40:24.058Z",' &&
                           '      "addresses": [' &&
                           '        {' &&
                           '          "id": "0b568175-1c30-434f-93d5-cce8fe290109",' &&
                           '          "country": "Brazil",' &&
                           '          "country_code": "123",' &&
                           '          "main": true,' &&
                           '          "zip_code": 10010000,' &&
                           '          "uf": "SP",' &&
                           '          "uf_code": "123",' &&
                           '          "city_code": "7107",' &&
                           '          "city": "New York",' &&
                           '          "type": "Avenida",' &&
                           '          "public_place": "Pixar",' &&
                           '          "home_number": "320B",' &&
                           '          "neighborhood": "Villa",' &&
                           '          "complement": "Home",' &&
                           '          "reference_point": "in the middle",' &&
                           '          "province": "New York",' &&
                           '          "category": "tax"' &&
                           '        }' &&
                           '      ],' &&
                           '      "fiscal_ids": [' &&
                           '        {' &&
                           '          "id": "0b568175-1c30-434f-93d5-cce8fe290109",' &&
                           '          "type": "RG",' &&
                           '          "value": "MG12345",' &&
                           '          "issuer": "Polícia Civil"' &&
                           '        }' &&
                           '      ],' &&
                           '      "contacts": [' &&
                           '        {' &&
                           '          "id": "172c4ad5-8924-44e1-a726-7b484d20e7f2",' &&
                           '          "type": "EMAIL",' &&
                           '          "value": {' &&
                           '            "address": "my@email.com"' &&
                           '          },' &&
                           '          "observation": "my email",' &&
                           '          "responsible": "my email"' &&
                           '        }' &&
                           '      ]' &&
                           '    }' &&
                           '  }' &&
                           '}'.

    expected_output = VALUE /s4tax/s_search_partner_o(
      data = VALUE /s4tax/s_data_partner(
        partner = VALUE /s4tax/s_partner(
          id = '172c4ad5-8924-44e1-a726-7b484d20e7f2'
          name = 'John Doe LTDA'
          fantasy_name = 'John Doe LTDA'
          birth_date = '2012-04-23T18:25:43.511Z'
          partner_type = 'PJ'
          created_at = '2023-07-18T21:40:24.058Z'
          updated_at = '2023-07-18T21:40:24.058Z'
          addresses = VALUE /s4tax/s_addresses_t(
              ( id = '0b568175-1c30-434f-93d5-cce8fe290109'
              country = 'Brazil'
              country_code = '123'
              zip_code = '10010000'
              main = abap_true
              uf = 'SP'
              uf_code = '123'
              city_code = '7107'
              city = 'New York'
              type = 'Avenida'
              public_place = 'Pixar'
              home_number = '320B'
              neighborhood = 'Villa'
              complement = 'Home'
              reference_point = 'in the middle'
              province = 'New York'
              category = 'tax' )
          )
          fiscal_ids = VALUE /s4tax/s_fiscal_ids_t(
              ( id = '0b568175-1c30-434f-93d5-cce8fe290109'
              type = 'RG'
              value = 'MG12345'
              issuer = 'Polícia Civil' )
          )
          contacts = VALUE /s4tax/s_contacts_t(
              ( id = '172c4ad5-8924-44e1-a726-7b484d20e7f2'
              type = 'EMAIL'
              value = VALUE /s4tax/s_value( address = 'my@email.com' )
              observation = 'my email'
              responsible = 'my email' )
          )
        )
      )
    ).

    response->if_http_response~set_cdata( data = valid_response ).

    TRY.
        output = cut->zis_iapi_partner~search_partner( partner_id = partner_id ).
      CATCH /s4tax/cx_http.
    ENDTRY.

    cut->get_last_request(  )->get_status( IMPORTING code = status_code ).

    cl_abap_unit_assert=>assert_equals( act = output
                                        exp = expected_output ).

    cl_abap_unit_assert=>assert_equals( act = status_code
                                        exp = 200 ).

  ENDMETHOD.

  METHOD error_get_partner_by_id.
    DATA: actual_output   TYPE /s4tax/s_default_error,
          expected_output TYPE /s4tax/s_default_error,
          partner_id      TYPE string.

    partner_id = '172c4ad5-8924-44e1-a726-7b484d20e7f2'. "PARTNER ID QUALQUER

    DATA(fake_response) = '{' &&
                           '  "code": "400",' &&
                           '  "message": "Erro no teste"' &&
                           '}'.

    expected_output = VALUE /s4tax/s_default_error( code = '400'
                                                    message = 'Erro no teste' ).

    TRY.
        cut->zis_iapi_partner~search_partner( partner_id = partner_id ).
      CATCH /s4tax/cx_http.
    ENDTRY.

    response->if_http_response~set_cdata( data = fake_response ).

    cut->zis_iapi_partner~change_response_for_error( CHANGING response_data = actual_output  ).

    cl_abap_unit_assert=>assert_equals( act = actual_output-code
                                        exp = expected_output-code ).

  ENDMETHOD.

ENDCLASS.