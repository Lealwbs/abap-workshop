INTERFACE zis_iapi_partner
  PUBLIC .

  METHODS:
    search_partner
      IMPORTING partner_id    TYPE string
      RETURNING VALUE(result) TYPE /s4tax/s_search_partner_o
      RAISING   /s4tax/cx_http..

ENDINTERFACE.