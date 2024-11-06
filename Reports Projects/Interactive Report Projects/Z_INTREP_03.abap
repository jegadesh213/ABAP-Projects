*&---------------------------------------------------------------------*
*& Report Z_INTREP_03
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_intrep_03.

TABLES : zmm_header , zmm_item .

TYPES : BEGIN OF ty_table,
          doc_no              TYPE zmm_header-doc_no,
          doc_date            TYPE zmm_header-doc_date,
          movement_type       TYPE zmm_header-movement_type,
          company_code        TYPE zmm_header-movement_type,
          document_type       TYPE zmm_header-document_type,
          material_doc_status TYPE zmm_header-material_doc_status,
          total_quantity      TYPE zmm_header-total_quantity,
          warehouse           TYPE zmm_header-warehouse,
          currency            TYPE zmm_header-currency,
          created_by          TYPE zmm_header-created_by,
          creation_date       TYPE zmm_header-creation_date,

          item_no             TYPE zmm_item-item_no,
          material_id         TYPE zmm_item-material_id,
          quantity_moved      TYPE zmm_item-quantity_moved,
          storage_location    TYPE zmm_item-storage_location,
          material_type       TYPE zmm_item-material_type,
          uom                 TYPE zmm_item-uom,
          batch_no            TYPE zmm_item-batch_no,
        END OF ty_table.

DATA : it_table TYPE TABLE OF ty_table,
       wa_table TYPE ty_table.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : p_no FOR zmm_header-doc_no.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM get_data.
  PERFORM display_data.

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  SELECT a~doc_no  a~doc_date a~movement_type a~company_code a~document_type a~material_doc_status a~total_quantity a~warehouse a~currency a~created_by a~creation_date
    b~item_no b~material_id b~quantity_moved b~storage_location b~material_type b~uom b~batch_no FROM zmm_header AS a INNER JOIN zmm_item AS b ON a~doc_no = b~doc_no
    INTO CORRESPONDING FIELDS OF TABLE it_table WHERE a~doc_no IN p_no.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form display_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .

  WRITE : / 'Doc Num','Doc Date','Mov Type','Comp Code','Document Type','Doc Status','Quantity','Warehouse','Currency','Created By','Creation Date','Item Number','Material Id','Quantity Moved','Storage Location','Material Type','UOM','Batch Number'.
  LOOP AT it_table INTO wa_table.
    WRITE : /  wa_table-doc_no , wa_table-doc_date , wa_table-movement_type , wa_table-company_code , wa_table-document_type,wa_table-material_doc_status , wa_table-total_quantity
    , wa_table-warehouse , wa_table-currency, wa_table-created_by , wa_table-creation_date, wa_table-item_no , wa_table-material_id, wa_table-quantity_moved,wa_table-storage_location, wa_table-material_type ,
    wa_table-uom , wa_table-batch_no.
  ENDLOOP.
ENDFORM.