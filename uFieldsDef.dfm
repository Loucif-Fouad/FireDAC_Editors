object frmFieldsDef: TfrmFieldsDef
  Left = 0
  Top = 0
  Caption = 'FieldsDef'
  ClientHeight = 537
  ClientWidth = 803
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object spl1: TSplitter
    Left = 549
    Top = 0
    Height = 537
    Align = alRight
    ExplicitLeft = 408
    ExplicitTop = 240
    ExplicitHeight = 100
  end
  object dbgrdFields: TDBGrid
    Left = 0
    Top = 0
    Width = 549
    Height = 537
    Align = alClient
    DataSource = d_FieldDefs
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = [fsBold]
  end
  object lstTables: TListBox
    Left = 552
    Top = 0
    Width = 251
    Height = 537
    Align = alRight
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ItemHeight = 14
    ParentFont = False
    TabOrder = 1
    OnDblClick = lstTablesDblClick
  end
  object d_FieldDefs: TDataSource
    DataSet = dsFieldDefs
    Left = 400
    Top = 232
  end
  object dsFieldDefs: TFDQuery
    ObjectView = False
    IndexFieldNames = 'TABLE_NAME;FIELD_NAME'
    SQL.Strings = (
      'SELECT '
      'TABLE_NAME, '
      'FIELD_NAME, '
      'DISPLAY_LABEL, '
      'DISPLAY_FORMAT, '
      'EDIT_FORMAT,'
      'DEFAULT_EXPRESSION, '
      'VISIBLE FROM'
      'FD$FIELD_DEFS'
      '  ')
    Left = 400
    Top = 392
  end
  object FDTransaction: TFDTransaction
    Left = 400
    Top = 296
  end
end
