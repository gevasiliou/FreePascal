unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, HMILabel,
  HMIEdit;

type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    HMIEdit1: THMIEdit;
    HMILabel1: THMILabel;
    HMILabel2: THMILabel;
    HMILabel3: THMILabel;
    HMILabel4: THMILabel;
    HMILabel5: THMILabel;
    HMILabel6: THMILabel;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;
//  Form1: TForm;
implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.Button1Click(Sender: TObject);

begin
     Form2.Close;
    // Form1:=TForm.Create(self);Form1.Show;
//     Form2.Free;
//  ShowMessage('Hello There');
end;


end.

