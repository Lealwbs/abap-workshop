INTERFACE zis_idao PUBLIC.

  METHODS:
    save IMPORTING obj            TYPE REF TO zis_bo,
    get  IMPORTING vcount        TYPE zis_table_t-vcount
         RETURNING VALUE(result) TYPE REF TO zis_bo.

ENDINTERFACE.