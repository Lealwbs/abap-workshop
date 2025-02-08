FUNCTION z08_voo_4_1.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(V_CITY_FROM) TYPE  SPFLI-CITYFROM
*"     REFERENCE(V_AIRP_FROM) TYPE  SPFLI-AIRPFROM
*"     REFERENCE(V_CITY_TO) TYPE  SPFLI-CITYTO OPTIONAL
*"     REFERENCE(V_AIRP_TO) TYPE  SPFLI-AIRPTO OPTIONAL
*"  EXPORTING
*"     VALUE(IT_TABLE) TYPE  Z08_TABELA
*"----------------------------------------------------------------------

  IF v_city_to IS INITIAL AND v_airp_to IS INITIAL.
    SELECT carrid, connid, deptime
    FROM spfli
    INTO TABLE @it_table
    WHERE cityfrom = @v_city_from
    AND airpfrom = @v_airp_from.
  ENDIF.


  IF v_city_to IS NOT INITIAL AND v_airp_to IS INITIAL.
    SELECT carrid, connid, deptime
    FROM spfli
    INTO TABLE @it_table
    WHERE cityfrom = @v_city_from
    AND airpfrom = @v_airp_from
    AND cityto = @v_city_to.
  ENDIF.


  IF v_city_to IS INITIAL AND v_airp_to IS NOT INITIAL.
    SELECT carrid, connid, deptime
    FROM spfli
    INTO TABLE @it_table
    WHERE cityfrom = @v_city_from
      AND airpfrom = @v_airp_from
      AND airpto = @v_airp_to.
  ENDIF.


  IF v_city_to IS NOT INITIAL AND v_airp_to IS NOT INITIAL.
    SELECT carrid, connid, deptime
    FROM spfli
    INTO TABLE @it_table
    WHERE cityfrom = @v_city_from
      AND airpfrom = @v_airp_from
      AND cityto = @v_city_to
      AND airpto = @v_airp_to.
  ENDIF.


  SELECT spfli~carrid, spfli~connid, spfli~deptime, COUNT( sflight~carrid ) AS v_count_flights
  FROM spfli
  LEFT JOIN sflight
         ON spfli~carrid = sflight~carrid
        AND spfli~connid = sflight~connid
  WHERE spfli~cityfrom = @v_city_from
    AND spfli~airpfrom = @v_airp_from
  GROUP BY spfli~carrid, spfli~connid, spfli~deptime
  INTO TABLE @it_table.

ENDFUNCTION.