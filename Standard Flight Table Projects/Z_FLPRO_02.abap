*&---------------------------------------------------------------------*
*& Report Z_FLPRO_02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_flpro_02.

TABLES : stravelag,scustom.

TYPES : BEGIN OF ty_cust,
          agencynum TYPE stravelag-agencynum,
          tname     TYPE stravelag-name,
          tcity     TYPE stravelag-city,

          id        TYPE scustom-id,
          cname     TYPE scustom-name,
          from      TYPE scustom-form,
          ccity     TYPE scustom-city,

        END OF ty_cust.

DATA : it_cust TYPE TABLE OF ty_cust,
       wa_cust TYPE ty_cust.

DATA : fld(20) TYPE c,
       val(20) TYPE c.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  PARAMETERS : p_c TYPE stravelag-mandt.

SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.

  PERFORM fetch_data.
  PERFORM show_data.

AT LINE-SELECTION.

  GET CURSOR FIELD fld VALUE val.

  IF fld = 'WA_CUST-AGENCYNUM' OR fld = 'WA_CUST-NAME' OR fld = 'WA_CUST-CITY'.

    SELECT * FROM stravelag INTO TABLE @DATA(it_stravelag).

    WRITE : 'Agency Number' ,20 'City' ,40 'Country' ,60 'Currency' ,80 'Language' ,100 'Telephone'.
    ULINE.

    LOOP AT it_stravelag INTO DATA(wa_stravelag).
      WRITE : / wa_stravelag-agencynum ,20 wa_stravelag-city ,40 wa_stravelag-country ,60 wa_stravelag-currency ,80 wa_stravelag-langu ,100 wa_stravelag-telephone.
    ENDLOOP.

  ELSE.

    SELECT * FROM scustom INTO TABLE @DATA(it_scustom).

    WRITE : 'Customer ID' ,20 'Customer Name' ,40 'Customer City' ,60 'Country' ,80 'From'.
    ULINE.

    LOOP AT it_scustom INTO DATA(wa_scustom).
      WRITE : / wa_scustom-id ,20 wa_scustom-name ,40 wa_scustom-city ,60 wa_scustom-country ,80 wa_scustom-form  .
    ENDLOOP.

  ENDIF.

TOP-OF-PAGE DURING LINE-SELECTION.

  CASE sy-lsind.
    WHEN 1.
      WRITE : 'Agency Details' COLOR 1.
      ULINE.
    WHEN 2.
      WRITE : 'Customer Details' COLOR 3.
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
  SELECT a~agencynum a~name a~city b~id b~name b~form b~city FROM stravelag AS a INNER JOIN scustom AS b ON a~mandt = b~mandt INTO TABLE it_cust
    WHERE a~mandt = p_c.
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

  WRITE : 'Agency Number' ,20 'Agency Name' ,41 'Agency City' ,60 'Customer ID' ,80 'Customer Name' ,100 'Customer From' ,120 'Customer City'.
  ULINE.

  LOOP AT it_cust INTO wa_cust.
    WRITE : / wa_cust-agencynum COLOR 1 HOTSPOT,20 wa_cust-tname COLOR 1 HOTSPOT,41 wa_cust-tcity COLOR 1 HOTSPOT,
              60 wa_cust-id COLOR 3 HOTSPOT,80 wa_cust-cname COLOR 3 HOTSPOT,100 wa_cust-from COLOR 3 HOTSPOT,120 wa_cust-ccity COLOR 3 HOTSPOT.
    HIDE :  wa_cust-agencynum , wa_cust-tname , wa_cust-tcity , wa_cust-id , wa_cust-cname , wa_cust-from , wa_cust-ccity.
  ENDLOOP.
ENDFORM.