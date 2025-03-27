*&---------------------------------------------------------------------*
*& Report zis_api_program
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zis_api_program.

DATA: pid1 TYPE string VALUE '8c8ff9e0-3811-48a1-bb86-6d6a53d6b0f3', "PARTNER INVÁLIDO
      pid2 TYPE string VALUE '20700980-f726-42bc-907b-945e07cd7d27', "PARTNER INVÁLIDO
      pid3 TYPE string VALUE 'e5a11447-07ca-4b0e-8f4e-30c6ec023ef5', "PARTNER
      pid4 TYPE string VALUE '', "PARTNER
      pid5 TYPE string VALUE ''. "PARTNER

DATA: wa_response TYPE /s4tax/s_search_partner_o.


START-OF-SELECTION.

  DATA: main TYPE REF TO zis_api_partner_run.
  CREATE OBJECT main.
  main->run( EXPORTING partnerid       = pid1
             CHANGING  return_response = wa_response ).

* TODO IMPLEMENTAR
*  IF wa_response IS NOT BOUND.
*    WRITE: wa_response.
*  ENDIF.

  PERFORM write_response USING wa_response.

END-OF-SELECTION.

FORM write_response USING response TYPE /s4tax/s_search_partner_o.

  IF response IS INITIAL.
    WRITE: / 'ERROR: The write_response form was called, but the response is empty'.
    RETURN.
  ENDIF.

  WRITE: / 'Partner ID:   ', response-data-partner-id,
         / 'Partner Name: ', response-data-partner-name,
         / 'Fantasy Name: ', response-data-partner-fantasy_name,
         / 'Birth Date:   ', response-data-partner-birth_date,
         / 'Partner Type: ', response-data-partner-partner_type,
         / 'Created at:   ', response-data-partner-created_at,
         / 'Updated at:   ', response-data-partner-updated_at.

  ULINE.
  WRITE: / 'Address ID:      ', response-data-partner-addresses-id,
         / 'Country:         ', response-data-partner-addresses-country,
         / 'Country_code:    ', response-data-partner-addresses-country_code,
         / 'Zip_code:        ', response-data-partner-addresses-zip_code,
         / 'Main:            ', response-data-partner-addresses-main,
         / 'UF:              ', response-data-partner-addresses-uf,
         / 'UF_code:         ', response-data-partner-addresses-uf_code,
         / 'City_code:       ', response-data-partner-addresses-city_code,
         / 'City:            ', response-data-partner-addresses-city,
         / 'Type:            ', response-data-partner-addresses-type,
         / 'Public_place:    ', response-data-partner-addresses-public_place,
         / 'Home_number:     ', response-data-partner-addresses-home_number,
         / 'Neighborhood:    ', response-data-partner-addresses-neighborhood,
         / 'Complement:      ', response-data-partner-addresses-complement,
         / 'Reference_point: ', response-data-partner-addresses-reference_point,
         / 'Province:        ', response-data-partner-addresses-province,
         / 'Category:        ', response-data-partner-addresses-category.

  ULINE.
  WRITE: / 'Fiscal ID:       ', response-data-partner-fiscal_ids-id,
         / 'Fiscal Type:     ', response-data-partner-fiscal_ids-type,
         / 'Fiscal Value:    ', response-data-partner-fiscal_ids-value,
         / 'Fiscal Issuer:   ', response-data-partner-fiscal_ids-issuer.


  ULINE.
  WRITE: / 'Contact ID:          ', response-data-partner-contacts-id,
         / 'Contact Type:        ', response-data-partner-contacts-type,
         / 'Contact Address:     ', response-data-partner-contacts-value-address,
         / 'Contact Observation: ', response-data-partner-contacts-observation,
         / 'Contact Responsible: ', response-data-partner-contacts-responsible.

ENDFORM.