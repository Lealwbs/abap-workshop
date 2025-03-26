*&---------------------------------------------------------------------*
*& Report zis_api_program
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zis_api_program.

DATA: pid1 TYPE string VALUE '8c8ff9e0-3811-48a1-bb86-6d6a53d6b0f3', "PARTNER VÁLIDO
      pid2 TYPE string VALUE '20700980-f726-42bc-907b-945e07cd7d27'. "PARTNER INVÁLIDO

START-OF-SELECTION.

  DATA: main TYPE REF TO zis_api_partner_run.
  CREATE OBJECT main.
  main->run( partnerid = pid2 ).