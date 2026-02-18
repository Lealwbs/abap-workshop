*&---------------------------------------------------------------------*
*& Report zis_api_program
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zis_api_program.

TYPES: BEGIN OF return_struct,
         success        TYPE abap_bool,
         return_partner TYPE /s4tax/s_search_partner_o,
         return_error   TYPE string,
       END OF return_struct.

DATA: pid1 TYPE string VALUE '8c8ff9e0-3811-48a1-bb86-6d6a53d6b0f3', "PARTNER VÁLIDO
      pid2 TYPE string VALUE '20700980-f726-42bc-907b-945e07cd7d27', "PARTNER INVÁLIDO
      pid3 TYPE string VALUE 'e5a11447-07ca-4b0e-8f4e-30c6ec023ef5', "PARTNER VÁLIDO
      pid4 TYPE string VALUE '172c4ad5-8924-44e1-a726-7b484d20e7f2', "PARTNER DA API
      pid5 TYPE string VALUE ''. "PARTNER

DATA: l_response TYPE return_struct.

START-OF-SELECTION.

  DATA: main TYPE REF TO zis_api_partner_run.

  TRY.
      CREATE OBJECT main.
    CATCH /s4tax/cx_http /s4tax/cx_autH.
      WRITE: / 'ERROR: It was not possible to call the API'.
  ENDTRY.

  l_response = main->run( EXPORTING partnerid = pid1 ).

  IF l_response-success EQ abap_true.
    WRITE: / '--- SUCCESS ---'. ULINE.
    PERFORM write_response USING l_response.
  ELSE.
    WRITE: / '--- RESPONSE IS EMPTY ---'. ULINE.
    WRITE: l_response-return_error.
  ENDIF.

END-OF-SELECTION.

FORM write_response USING response TYPE return_struct.

  IF response IS INITIAL.
    WRITE: / 'ERROR: The write_response form was called, but the response is empty'.
    RETURN.
  ENDIF.

  WRITE: / 'Partner ID:   ', response-return_partner-data-partner-id,
         / 'Partner Name: ', response-return_partner-data-partner-name,
         / 'Fantasy Name: ', response-return_partner-data-partner-fantasy_name,
         / 'Birth Date:   ', response-return_partner-data-partner-birth_date,
         / 'Partner Type: ', response-return_partner-data-partner-partner_type,
         / 'Created at:   ', response-return_partner-data-partner-created_at,
         / 'Updated at:   ', response-return_partner-data-partner-updated_at.
  ULINE.

  LOOP AT response-return_partner-data-partner-addresses INTO DATA(address).
  WRITE: / 'Address ID:      ', address-id,
         / 'Country:         ', address-country,
         / 'Country_code:    ', address-country_code,
         / 'Zip_code:        ', address-zip_code,
         / 'Main:            ', address-main,
         / 'UF:              ', address-uf,
         / 'UF_code:         ', address-uf_code,
         / 'City_code:       ', address-city_code,
         / 'City:            ', address-city,
         / 'Type:            ', address-type,
         / 'Public_place:    ', address-public_place,
         / 'Home_number:     ', address-home_number,
         / 'Neighborhood:    ', address-neighborhood,
         / 'Complement:      ', address-complement,
         / 'Reference_point: ', address-reference_point,
         / 'Province:        ', address-province,
         / 'Category:        ', address-category.
  ULINE.
  ENDLOOP.

  LOOP AT response-return_partner-data-partner-fiscal_ids INTO DATA(fiscal_id).
  WRITE: / 'Fiscal ID:       ', fiscal_id-id,
         / 'Fiscal Type:     ', fiscal_id-type,
         / 'Fiscal Value:    ', fiscal_id-value,
         / 'Fiscal Issuer:   ', fiscal_id-issuer.
  ULINE.
  ENDLOOP.

  LOOP AT response-return_partner-data-partner-contacts INTO DATA(contact).
  WRITE: / 'Contact ID:          ', contact-id,
         / 'Contact Type:        ', contact-type,
         / 'Contact Address:     ', contact-value-address,
         / 'Contact Observation: ', contact-observation,
         / 'Contact Responsible: ', contact-responsible.
  ENDLOOP.

ENDFORM.