*&---------------------------------------------------------------------*
*& Report Z_FLPRO_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_flpro_01.

TABLES : scarr,scounter,spfli,sflight.

TYPES : BEGIN OF ty_flt,
          carrid     TYPE scarr-carrid,
          airport    TYPE scounter-airport,
          cityfrom   TYPE spfli-cityfrom,
          cityto     TYPE spfli-cityto,
          fldate     TYPE sflight-fldate,
          price      TYPE sflight-price,
          currency   TYPE sflight-currency,
          paymentsum TYPE sflight-paymentsum,
        END OF ty_flt.

DATA : it_flt TYPE TABLE OF ty_flt,
       wa_flt TYPE ty_flt.

"Custom data declaration to know where the user Clicks
DATA : fld(20) TYPE c,
       val(20) TYPE c.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_car FOR scarr-carrid.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM fetch_data.
  PERFORM show_data.


AT LINE-SELECTION.
  SELECT a~carrid b~airport c~cityfrom c~cityto d~fldate d~price d~currency d~paymentsum INTO CORRESPONDING FIELDS OF TABLE it_flt
    FROM scarr AS a INNER JOIN scounter AS b ON a~carrid = b~carrid
                    INNER JOIN spfli AS c ON a~carrid = c~carrid
                    INNER JOIN sflight AS d ON a~carrid = d~carrid WHERE a~carrid = wa_flt-carrid OR c~cityfrom = wa_flt-cityfrom.

  IF sy-lsind = 1.

    GET CURSOR FIELD fld VALUE val.

    IF fld = 'WA_FLT-AIRPORT'.

      SELECT a~carrid b~airport c~cityfrom c~cityto d~fldate d~price d~currency d~paymentsum INTO CORRESPONDING FIELDS OF TABLE it_flt
    FROM scarr AS a INNER JOIN scounter AS b ON a~carrid = b~carrid
                    INNER JOIN spfli AS c ON a~carrid = c~carrid
                    INNER JOIN sflight AS d ON a~carrid = d~carrid WHERE b~airport = wa_flt-airport .

      LOOP AT it_flt INTO wa_flt.
        WRITE : / wa_flt-carrid ,20 wa_flt-airport COLOR 1,40 wa_flt-cityfrom ,60 wa_flt-cityto ,80 wa_flt-fldate ,100 wa_flt-price LEFT-JUSTIFIED,120 wa_flt-currency ,
      140 wa_flt-paymentsum LEFT-JUSTIFIED HOTSPOT COLOR 3.
        HIDE :  wa_flt-carrid , wa_flt-airport , wa_flt-cityfrom , wa_flt-cityto , wa_flt-fldate , wa_flt-price , wa_flt-currency ,
      wa_flt-paymentsum .
      ENDLOOP.


    ELSE.

      WRITE :/ 'CARR ID' ,20 'AIRPORT' ,40 'FROM' ,60 'TO' ,80 'DATE' ,100 'PRICE' ,120 'CURRENCY' ,140 'PAYMENTSUM'.
      ULINE.

      LOOP AT it_flt INTO wa_flt.
        WRITE : / wa_flt-carrid ,20 wa_flt-airport ,40 wa_flt-cityfrom COLOR 1,60 wa_flt-cityto ,80 wa_flt-fldate ,100 wa_flt-price LEFT-JUSTIFIED,120 wa_flt-currency ,
      140 wa_flt-paymentsum LEFT-JUSTIFIED HOTSPOT COLOR 3.
        HIDE :  wa_flt-carrid , wa_flt-airport , wa_flt-cityfrom , wa_flt-cityto , wa_flt-fldate , wa_flt-price , wa_flt-currency ,
      wa_flt-paymentsum .
      ENDLOOP.

    ENDIF.

  ELSEIF sy-lsind = 2 .

    SELECT a~carrid b~airport c~cityfrom c~cityto d~fldate d~price d~currency d~paymentsum INTO CORRESPONDING FIELDS OF TABLE it_flt
    FROM scarr AS a INNER JOIN scounter AS b ON a~carrid = b~carrid
                    INNER JOIN spfli AS c ON a~carrid = c~carrid
                    INNER JOIN sflight AS d ON a~carrid = d~carrid WHERE d~paymentsum = wa_flt-paymentsum.

    WRITE :/ 'CARR ID' ,20 'AIRPORT' ,40 'PAYMENTSUM'.
    ULINE.

    LOOP AT it_flt INTO wa_flt.
      WRITE : / wa_flt-carrid ,20 wa_flt-airport ,40 wa_flt-paymentsum LEFT-JUSTIFIED COLOR 1.
    ENDLOOP.

  ENDIF.


TOP-OF-PAGE DURING LINE-SELECTION.

  CASE sy-lsind.
    WHEN 1.
      IF fld = 'WA_FLT-AIRPORT'.
        WRITE : 'LEVEL 1 : ' COLOR 3 , wa_flt-airport .
        ULINE.
      ELSE.
        WRITE : 'LEVEL 1 : ' COLOR 3 , wa_flt-cityfrom .
        ULINE.
      ENDIF.
    WHEN 2.
      WRITE : 'LEVEL 2 : ' COLOR 4 , wa_flt-paymentsum.
      ULINE.
  ENDCASE.

*&---------------------------------------------------------------------*
*& Form fetch_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fetch_data .
  SELECT a~carrid b~airport c~cityfrom c~cityto d~fldate d~price d~currency d~paymentsum INTO CORRESPONDING FIELDS OF TABLE it_flt
    FROM scarr AS a INNER JOIN scounter AS b ON a~carrid = b~carrid
                    INNER JOIN spfli AS c ON a~carrid = c~carrid
                    INNER JOIN sflight AS d ON a~carrid = d~carrid WHERE a~carrid IN s_car.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form show_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_data .

  WRITE : 'CARR ID' ,20 'AIRPORT' ,40 'FROM' ,60 'TO' ,80 'DATE' ,100 'PRICE' ,120 'CURRENCY' ,140 'PAYMENTSUM'.
  ULINE.
  LOOP AT it_flt INTO wa_flt.
    WRITE : / wa_flt-carrid ,20 wa_flt-airport HOTSPOT COLOR 3,40 wa_flt-cityfrom HOTSPOT COLOR 3,60 wa_flt-cityto ,80 wa_flt-fldate ,100 wa_flt-price LEFT-JUSTIFIED,120 wa_flt-currency ,
    140 wa_flt-paymentsum LEFT-JUSTIFIED.
    HIDE :  wa_flt-carrid , wa_flt-airport , wa_flt-cityfrom , wa_flt-cityto , wa_flt-fldate , wa_flt-price , wa_flt-currency ,
    wa_flt-paymentsum .
  ENDLOOP.

ENDFORM.
