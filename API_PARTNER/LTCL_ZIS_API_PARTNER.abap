*"* use this source file for your ABAP unit test classes
CLASS ltcl_zis_api_partner DEFINITION FINAL FOR TESTING
  INHERITING FROM /s4tax/api_signed_test
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    DATA: cut TYPE REF TO zis_api_partner.

    METHODS:
      setup,
      get_instance FOR TESTING.

ENDCLASS.


CLASS ltcl_zis_api_partner IMPLEMENTATION.

  METHOD setup.

    DATA: defaults TYPE REF TO /s4tax/defaults.
    mount_data(  ).
    mock_configuration(  ).

    defaults = NEW #( mock_dao_pack ).
    cut = NEW #( session = session defaults = defaults ).

  ENDMETHOD.

  METHOD get_instance.

    DATA: instance TYPE REF TO zis_iapi_partner.
    mock_configuration(  ).

    instance = zis_api_partner=>get_instance( mock_api_auth ).
    cl_abap_unit_assert=>assert_bound( instance ).

  ENDMETHOD.

ENDCLASS.

*    "id": "e5a11447-07ca-4b0e-8f4e-30c6ec023ef5",
*    "id": "07116020-a9c9-46cb-a188-bebad790d4dc",
*    "id": "09423257-b7d6-44ce-88af-7c01dcbca2a6",
*    "id": "9f3813f0-6df6-4c46-91f9-8a8dc214023c",
*    "id": "659cf7b8-6769-44ce-86c1-f418bba1a342",
*    "id": "6514df81-fbc7-4e58-896a-1e3bc270257f",
*    "id": "12fd95fc-40dd-45e8-8cf4-3fc340a32826",
*    "id": "0e934936-7192-4b45-a146-df7d4e503c6c",
*    "id": "e7bb0c60-bc80-42d6-b82a-3e2da49dcb7f",
*    "id": "e7975e28-ef87-4f3e-adf0-7cc8ec0c2eff",
*    "id": "b979a761-70dc-45a4-8751-572c7e24bc51",
*    "id": "637308c5-9124-4e19-a9b4-a1e0c2ecf2e3",
*    "id": "4a15b896-d3a5-43e5-aa94-93766faa0937",
*    "id": "6768aefc-9564-409a-8232-39ed128c0b57",
*    "id": "75459c4a-3b0c-4967-b6f2-0707f918820f",
*    "id": "5afd1bd7-e54e-4676-80a9-9870477b432a",
*    "id": "6f0872bc-ab6f-4a54-a882-d5bcbf22882f",
*    "id": "8b9f221b-ae70-4904-b14a-1c5730803838",
*    "id": "05627153-dbbc-49b0-b0b4-2c16854316cc",
*    "id": "cf11c9ab-f441-4ca3-9caa-093654cd35f6",
