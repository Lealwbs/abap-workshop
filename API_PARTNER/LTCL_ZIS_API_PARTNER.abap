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
*    "name": "Teste 3",
*    "fantasy_name": "",
*    "birth_date": null,
*    "fiscal_id_number": "00770442000117",
*    "partner_type": "PJ",
*    "created_at": "2024-12-19T13:52:09.341Z",
*    "updated_at": "2025-01-23T16:48:06.874Z",
*    "roles": [
*        {
*            "id": "e5a11447-07ca-4b0e-8f4e-30c6ec023ef5",
*            "type": "branch",
*            "association_tenant_id": "31060558-e334-4f1e-9681-2e01d3697e35",
*            "inactive_at": null
*        }
*    ]
*},
*{
*    "id": "07116020-a9c9-46cb-a188-bebad790d4dc",
*    "name": "Daniel Pereira da Silva",
*    "fantasy_name": "Danizinho 22",
*    "birth_date": null,
*    "fiscal_id_number": "00849889000186",
*    "partner_type": "PJ",
*    "created_at": "2024-12-19T13:52:18.655Z",
*    "updated_at": "2024-12-19T13:52:18.655Z",
*    "roles": []
*},
*{
*    "id": "09423257-b7d6-44ce-88af-7c01dcbca2a6",
*    "name": "Teste 2",
*    "fantasy_name": "",
*    "birth_date": null,
*    "fiscal_id_number": "02858031000103",
*    "partner_type": "PJ",
*    "created_at": "2024-12-19T13:52:25.209Z",
*    "updated_at": "2025-01-02T17:04:39.423Z",
*    "roles": [
*        {
*            "id": "09423257-b7d6-44ce-88af-7c01dcbca2a6",
*            "type": "branch",
*            "association_tenant_id": "31060558-e334-4f1e-9681-2e01d3697e35",
*            "inactive_at": null
*        }
*    ]
*},
*{
*    "id": "9f3813f0-6df6-4c46-91f9-8a8dc214023c",
*    "name": "Allugator Filial Teste 2",
*    "fantasy_name": "Filial Teste 2",
*    "birth_date": null,
*    "fiscal_id_number": "03424612000108",
*    "partner_type": "PJ",
*    "created_at": "2024-12-19T13:52:31.762Z",
*    "updated_at": "2024-12-19T13:52:31.762Z",
*    "roles": []
*},
*{
*    "id": "659cf7b8-6769-44ce-86c1-f418bba1a342",
*    "name": "pedro silveira",
*    "fantasy_name": "",
*    "birth_date": null,
*    "fiscal_id_number": "03613748000158",
*    "partner_type": "PJ",
*    "created_at": "2024-12-19T13:52:37.598Z",
*    "updated_at": "2024-12-19T13:52:37.598Z",
*    "roles": []
*},
*{
*    "id": "6514df81-fbc7-4e58-896a-1e3bc270257f",
*    "name": "Anhanguera Educacional Participaçõe  Cogna 1047",
*    "fantasy_name": "Anhanguera Educacional Participaçõe  Cogna 1047",
*    "birth_date": null,
*    "fiscal_id_number": "04310392004729",
*    "partner_type": "PJ",
*    "created_at": "2024-12-19T13:52:43.744Z",
*    "updated_at": "2025-01-02T17:04:39.991Z",
*    "roles": [
*        {
*            "id": "6514df81-fbc7-4e58-896a-1e3bc270257f",
*            "type": "branch",
*            "association_tenant_id": "31060558-e334-4f1e-9681-2e01d3697e35",
*            "inactive_at": null
*        }
*    ]
*},
*{
*    "id": "12fd95fc-40dd-45e8-8cf4-3fc340a32826",
*    "name": "pedro silveira",
*    "fantasy_name": "",
*    "birth_date": null,
*    "fiscal_id_number": "05138106000170",
*    "partner_type": "PJ",
*    "created_at": "2024-12-19T13:52:50.192Z",
*    "updated_at": "2024-12-19T13:52:50.192Z",
*    "roles": []
*},
*{
*    "id": "0e934936-7192-4b45-a146-df7d4e503c6c",
*    "name": "pedro silveira",
*    "fantasy_name": "",
*    "birth_date": null,
*    "fiscal_id_number": "05620635000105",
*    "partner_type": "PJ",
*    "created_at": "2024-12-19T13:52:56.541Z",
*    "updated_at": "2024-12-19T13:52:56.541Z",
*    "roles": []
*},
*{
*    "id": "e7bb0c60-bc80-42d6-b82a-3e2da49dcb7f",
*    "name": "FELLIPELLI INST DE DIAG E DES ORG LTDA",
*    "fantasy_name": "FELLIPELLI INSTRUMENTOS DE DIAGNOSTICO DESENVOLVIMENTO",
*    "birth_date": null,
*    "fiscal_id_number": "07792897000182",
*    "partner_type": "PJ",
*    "created_at": "2024-12-19T13:53:04.018Z",
*    "updated_at": "2024-12-19T13:53:04.018Z",
*    "roles": []
*},
*{
*    "id": "e7975e28-ef87-4f3e-adf0-7cc8ec0c2eff",
*    "name": "Test Branch",
*    "fantasy_name": "Test Branch",
*    "birth_date": null,
*    "fiscal_id_number": "08684547000165",
*    "partner_type": "PJ",
*    "created_at": "2024-12-19T13:53:11.040Z",
*    "updated_at": "2025-01-02T17:04:36.181Z",
*    "roles": []
*},
*{
*    "id": "b979a761-70dc-45a4-8751-572c7e24bc51",
*    "name": "Seidor veritas",
*    "fantasy_name": "Seidor veritas",
*    "birth_date": null,
*    "fiscal_id_number": "10254592000121",
*    "partner_type": "PJ",
*    "created_at": "2024-12-19T13:53:17.591Z",
*    "updated_at": "2025-01-02T17:04:38.841Z",
*    "roles": [
*        {
*            "id": "b979a761-70dc-45a4-8751-572c7e24bc51",
*            "type": "branch",
*            "association_tenant_id": "31060558-e334-4f1e-9681-2e01d3697e35",
*            "inactive_at": null
*        }
*    ]
*},
*{
*    "id": "637308c5-9124-4e19-a9b4-a1e0c2ecf2e3",
*    "name": "GOL",
*    "fantasy_name": "Tracevia S/A",
*    "birth_date": null,
*    "fiscal_id_number": "10372511000198",
*    "partner_type": "PJ",
*    "created_at": "2024-12-19T13:53:23.681Z",
*    "updated_at": "2024-12-19T13:53:23.681Z",
*    "roles": [
*        {
*            "id": "637308c5-9124-4e19-a9b4-a1e0c2ecf2e3",
*            "type": "branch",
*            "association_tenant_id": "31060558-e334-4f1e-9681-2e01d3697e35",
*            "inactive_at": null
*        }
*    ]
*},
*{
*    "id": "4a15b896-d3a5-43e5-aa94-93766faa0937",
*    "name": "pedro silveira",
*    "fantasy_name": "",
*    "birth_date": null,
*    "fiscal_id_number": "11071284000123",
*    "partner_type": "PJ",
*    "created_at": "2024-12-19T13:53:29.718Z",
*    "updated_at": "2024-12-19T13:53:29.719Z",
*    "roles": []
*},
*{
*    "id": "6768aefc-9564-409a-8232-39ed128c0b57",
*    "name": "ddd",
*    "fantasy_name": "ddd",
*    "birth_date": null,
*    "fiscal_id_number": "11117386000132",
*    "partner_type": "PJ",
*    "created_at": "2024-12-19T13:53:35.966Z",
*    "updated_at": "2024-12-19T13:53:35.966Z",
*    "roles": [
*        {
*            "id": "6768aefc-9564-409a-8232-39ed128c0b57",
*            "type": "branch",
*            "association_tenant_id": "31060558-e334-4f1e-9681-2e01d3697e35",
*            "inactive_at": null
*        }
*    ]
*},
*{
*    "id": "75459c4a-3b0c-4967-b6f2-0707f918820f",
*    "name": "testeli1",
*    "fantasy_name": "",
*    "birth_date": null,
*    "fiscal_id_number": "11452643000192",
*    "partner_type": "PJ",
*    "created_at": "2024-12-19T13:53:42.314Z",
*    "updated_at": "2024-12-19T13:53:42.314Z",
*    "roles": []
*},
*{
*    "id": "5afd1bd7-e54e-4676-80a9-9870477b432a",
*    "name": "TRANSFERO BRASIL PAGAMENTOS SA",
*    "fantasy_name": "TRANSFERO BRASIL PAGAMENTOS SA",
*    "birth_date": null,
*    "fiscal_id_number": "11480809000184",
*    "partner_type": "PJ",
*    "created_at": "2024-12-19T13:53:48.458Z",
*    "updated_at": "2024-12-19T13:53:48.458Z",
*    "roles": []
*},
*{
*    "id": "6f0872bc-ab6f-4a54-a882-d5bcbf22882f",
*    "name": "ICOPLAS INDUSTRIA DE FRASCOS LTDA",
*    "fantasy_name": "ICOPLAS INDUSTRIA DE FRASCOS LTDA",
*    "birth_date": null,
*    "fiscal_id_number": "11629048000180",
*    "partner_type": "PJ",
*    "created_at": "2024-12-19T13:53:54.208Z",
*    "updated_at": "2024-12-19T13:53:54.209Z",
*    "roles": [
*        {
*            "id": "6f0872bc-ab6f-4a54-a882-d5bcbf22882f",
*            "type": "branch",
*            "association_tenant_id": "31060558-e334-4f1e-9681-2e01d3697e35",
*            "inactive_at": null
*        }
*    ]
*},
*{
*    "id": "8b9f221b-ae70-4904-b14a-1c5730803838",
*    "name": "Teste Cris 2 - DUP",
*    "fantasy_name": null,
*    "birth_date": null,
*    "fiscal_id_number": "13031875664",
*    "partner_type": "PF",
*    "created_at": "2024-12-19T13:54:01.367Z",
*    "updated_at": "2024-12-19T13:54:01.367Z",
*    "roles": [
*        {
*            "id": "8b9f221b-ae70-4904-b14a-1c5730803838",
*            "type": "branch",
*            "association_tenant_id": "31060558-e334-4f1e-9681-2e01d3697e35",
*            "inactive_at": null
*        }
*    ]
*},
*{
*    "id": "05627153-dbbc-49b0-b0b4-2c16854316cc",
*    "name": "gfgfgfgaf",
*    "fantasy_name": "",
*    "birth_date": null,
*    "fiscal_id_number": "13986007000176",
*    "partner_type": "PJ",
*    "created_at": "2024-12-19T13:54:08.221Z",
*    "updated_at": "2024-12-19T13:54:08.221Z",
*    "roles": [
*        {
*            "id": "05627153-dbbc-49b0-b0b4-2c16854316cc",
*            "type": "branch",
*            "association_tenant_id": "31060558-e334-4f1e-9681-2e01d3697e35",
*            "inactive_at": null
*
*
*    "id": "cf11c9ab-f441-4ca3-9caa-093654cd35f6",
*    "name": "dasdsad",
*    "fantasy_name": null,
*    "birth_date": null,
*    "fiscal_id_number": "14789524663",
*    "partner_type": "PF",
*    "created_at": "2024-12-19T13:54:14.467Z",
*    "updated_at": "2024-12-19T13:54:14.467Z",
*    "roles": []}