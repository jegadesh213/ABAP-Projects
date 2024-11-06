*&---------------------------------------------------------------------*
*& Report Z_INTREP_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_intrep_01.

TABLES : zso_header, zso_item , zdelivery_header, zdelivery_item.

TYPES : ty_soheader TYPE zso_header,
        ty_soitem   TYPE zso_item.

DATA : it_soheader TYPE TABLE OF ty_soheader,
       wa_soheader TYPE ty_soheader,
       it_soitem   TYPE TABLE OF ty_soitem,
       wa_soitem   TYPE ty_soitem.

TYPES : BEGIN OF ty_delidetail,

          delivery_no    TYPE zdelivery_header-delivery_no,
          order_no       TYPE zdelivery_header-order_no,
          delivery_date  TYPE zdelivery_header-delivery_date,
          shipping_point TYPE zdelivery_header-shipping_point,

          item_no        TYPE zdelivery_item-item_no,
          material_id    TYPE zdelivery_item-material_id,
          quantity       TYPE zdelivery_item-quantity,

        END OF ty_delidetail.

DATA : it_delidetail TYPE TABLE OF ty_delidetail,
       wa_delidetail TYPE ty_delidetail.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_num FOR zso_header-order_no.
SELECTION-SCREEN END OF BLOCK b1.



SELECT * FROM zso_header INTO CORRESPONDING FIELDS OF TABLE it_soheader WHERE order_no IN s_num.

WRITE : 'Order Number' ,15 'Order Date', 30 'Customer ID ',55 'Sales Organization', 90 'Total Amount'.
ULINE.

LOOP AT it_soheader INTO wa_soheader.
  WRITE : / wa_soheader-order_no ,15 wa_soheader-order_date LEFT-JUSTIFIED,30 wa_soheader-customer_id LEFT-JUSTIFIED,55 wa_soheader-sales_org LEFT-JUSTIFIED,90 wa_soheader-total_amount LEFT-JUSTIFIED.
  HIDE : wa_soheader-order_no , wa_soheader-order_date, wa_soheader-customer_id, wa_soheader-sales_org, wa_soheader-total_amount.
ENDLOOP.
ULINE.

AT LINE-SELECTION.

  IF sy-lsind = 1.

    WRITE : 'Order Number' ,15 'Item Number', 30 'Material ID ',55 'Quantity', 90 'Price'.
    ULINE.

    SELECT * FROM zso_item INTO CORRESPONDING FIELDS OF TABLE it_soitem WHERE order_no = wa_soheader-order_no.

    LOOP AT it_soitem INTO wa_soitem.
      WRITE : / wa_soitem-order_no ,15 wa_soitem-item_no LEFT-JUSTIFIED,30 wa_soitem-material_id LEFT-JUSTIFIED,55 wa_soitem-quantity LEFT-JUSTIFIED,90 wa_soitem-price LEFT-JUSTIFIED.
      HIDE :wa_soitem-order_no , wa_soitem-item_no, wa_soitem-material_id, wa_soitem-quantity, wa_soitem-price.
    ENDLOOP.

    ULINE.

  ELSEIF sy-lsind = 2.

    SELECT a~delivery_no a~order_no a~delivery_date a~shipping_point b~item_no b~material_id b~quantity
      FROM zdelivery_header AS a
      INNER JOIN zdelivery_item AS b ON a~delivery_no = b~delivery_no INTO CORRESPONDING FIELDS OF TABLE it_delidetail WHERE a~order_no = wa_soitem-order_no.

    WRITE : 'Delivery Number' ,20 'Order Num', 30 'Delivery Date ',55 'Shipping Point', 90 'Item No',110 'Material ID', 135 'Quantity'.
    ULINE.

    LOOP AT it_delidetail INTO wa_delidetail.
      WRITE : / wa_delidetail-delivery_no , 20 wa_delidetail-order_no LEFT-JUSTIFIED, 30 wa_delidetail-delivery_date LEFT-JUSTIFIED,
       55 wa_delidetail-shipping_point LEFT-JUSTIFIED, 90 wa_delidetail-item_no LEFT-JUSTIFIED,
      110 wa_delidetail-material_id LEFT-JUSTIFIED, 135 wa_delidetail-quantity LEFT-JUSTIFIED.
    ENDLOOP.

    ULINE.

  ENDIF.

TOP-OF-PAGE.

  WRITE : 'SALES ORDER HEADER DETAILS' COLOR 3.
  ULINE.

TOP-OF-PAGE DURING LINE-SELECTION.

  CASE sy-lsind.
    WHEN 1.
      WRITE : / 'SALES ORDER ITEM DETAILS' COLOR 5.
      ULINE.
    WHEN 2.
      WRITE : / 'ORDER DELIVERY DETAILS' COLOR 6.
    WHEN OTHERS.
  ENDCASE.