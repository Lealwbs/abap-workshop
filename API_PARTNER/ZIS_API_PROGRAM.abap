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

DATA: pid1 TYPE string VALUE '8c8ff9e0-3811-48a1-bb86-6d6a53d6b0f3', "PARTNER INVÁLIDO
      pid2 TYPE string VALUE '20700980-f726-42bc-907b-945e07cd7d27', "PARTNER INVÁLIDO
      pid3 TYPE string VALUE 'e5a11447-07ca-4b0e-8f4e-30c6ec023ef5', "PARTNER
      pid4 TYPE string VALUE '', "PARTNER
      pid5 TYPE string VALUE ''. "PARTNER

DATA: l_response TYPE return_struct.

START-OF-SELECTION.

  DATA: main TYPE REF TO zis_api_partner_run.
  CREATE OBJECT main.
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
  WRITE: / 'Address ID:      ', response-return_partner-data-partner-addresses-id,
         / 'Country:         ', response-return_partner-data-partner-addresses-country,
         / 'Country_code:    ', response-return_partner-data-partner-addresses-country_code,
         / 'Zip_code:        ', response-return_partner-data-partner-addresses-zip_code,
         / 'Main:            ', response-return_partner-data-partner-addresses-main,
         / 'UF:              ', response-return_partner-data-partner-addresses-uf,
         / 'UF_code:         ', response-return_partner-data-partner-addresses-uf_code,
         / 'City_code:       ', response-return_partner-data-partner-addresses-city_code,
         / 'City:            ', response-return_partner-data-partner-addresses-city,
         / 'Type:            ', response-return_partner-data-partner-addresses-type,
         / 'Public_place:    ', response-return_partner-data-partner-addresses-public_place,
         / 'Home_number:     ', response-return_partner-data-partner-addresses-home_number,
         / 'Neighborhood:    ', response-return_partner-data-partner-addresses-neighborhood,
         / 'Complement:      ', response-return_partner-data-partner-addresses-complement,
         / 'Reference_point: ', response-return_partner-data-partner-addresses-reference_point,
         / 'Province:        ', response-return_partner-data-partner-addresses-province,
         / 'Category:        ', response-return_partner-data-partner-addresses-category.

  ULINE.
  WRITE: / 'Fiscal ID:       ', response-return_partner-data-partner-fiscal_ids-id,
         / 'Fiscal Type:     ', response-return_partner-data-partner-fiscal_ids-type,
         / 'Fiscal Value:    ', response-return_partner-data-partner-fiscal_ids-value,
         / 'Fiscal Issuer:   ', response-return_partner-data-partner-fiscal_ids-issuer.


  ULINE.
  WRITE: / 'Contact ID:          ', response-return_partner-data-partner-contacts-id,
         / 'Contact Type:        ', response-return_partner-data-partner-contacts-type,
         / 'Contact Address:     ', response-return_partner-data-partner-contacts-value-address,
         / 'Contact Observation: ', response-return_partner-data-partner-contacts-observation,
         / 'Contact Responsible: ', response-return_partner-data-partner-contacts-responsible.

ENDFORM.