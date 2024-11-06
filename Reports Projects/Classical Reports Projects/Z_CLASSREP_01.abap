*&---------------------------------------------------------------------*
*& Report Z_CLASSREP_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_classrep_01.

TABLES : zinv_stock_loc,zmat_desc,zplant_desc.

TYPES : BEGIN OF ty_table,
          material_id   TYPE zinv_stock_loc-material_id,
          plant         TYPE zinv_stock_loc-plant,
          storage_loc   TYPE zinv_stock_loc-storage_loc,
          stock_qty     TYPE zinv_stock_loc-stock_qty,

          material_desc TYPE zmat_desc-material_desc,

          plant_name    TYPE zplant_desc-plant_name,
        END OF ty_table.

DATA : it_table TYPE TABLE OF ty_table,
       wa_table TYPE ty_table.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_id FOR zinv_stock_loc-material_id.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM fetch_data.
  PERFORM show_data.

*&---------------------------------------------------------------------*
*& Form fetch_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fetch_data .
  SELECT a~material_id a~plant a~storage_loc a~stock_qty b~Material_desc c~plant_name FROM zinv_stock_loc AS a INNER JOIN zmat_desc AS b
    ON a~material_id = b~material_id INNER JOIN zplant_desc AS c ON a~plant = c~plant INTO CORRESPONDING FIELDS OF TABLE it_table WHERE a~material_id IN s_id.
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
  WRITE : 'Material ID ' ,15 'Plant' ,45 'Storage Location',75 'Stock Quantity',100 'Material Description',125 'Plant Name'.
  ULINE.
  LOOP AT it_table INTO wa_table.
    WRITE : / wa_table-material_id ,15 wa_table-plant,45 wa_table-storage_loc ,75 wa_table-stock_qty,100 wa_table-material_desc ,125 wa_table-plant_name.
  ENDLOOP.
  ULINE.
ENDFORM.

TOP-OF-PAGE.

  WRITE : 'Inventory Stock Overview' COLOR 3.
  ULINE.