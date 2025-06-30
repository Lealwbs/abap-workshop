*----------------------------------------------------------------------*
***INCLUDE MZ_08_VOO_F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form busca_cia
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*

FORM busca_cia .

  SELECT SINGLE CARRNAME
    FROM scarr
    INTO scarr-carrname
    WHERE carrid = spfli-carrid.

  SELECT COUNT( * )
    FROM spfli
   WHERE carrid  = @spfli-carrid
     AND ( airpfrom = @spfli-airpfrom OR @spfli-airpfrom IS INITIAL )
    INTO @number_of_flights.
  IF sy-subrc <> 0.
    " CLEAR: NUMBER_OF_FLIGHTS.
  ENDIF.

ENDFORM.