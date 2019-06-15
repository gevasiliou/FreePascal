unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, ComCtrls, Grids, DateTimePicker, TAGraph, TARadialSeries, TASeries,
  tcp_udpport, ModBusTCP, PLCTagNumber, PLCBlock, PLCBlockElement, HMILabel,
  DateUtils, Crt, Unit2;

type

  { TForm1 }

  TForm1 = class(TForm)
    ConnectBtn: TButton;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    StopBtn: TButton;
    Button3: TButton;
    Button4: TButton;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    IdleTimer1: TIdleTimer;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ModBusTCPDriver1: TModBusTCPDriver;
    PLCBlock1: TPLCBlock;
    PLCBlockElement1: TPLCBlockElement;
    PLCBlockElement2: TPLCBlockElement;
    StringGrid1: TStringGrid;
    M1Volts: TPLCTagNumber;
    M2Volts: TPLCTagNumber;
    M1Temp: TPLCTagNumber;
    M2Temp: TPLCTagNumber;
    M3Volts: TPLCTagNumber;
    M3Temp: TPLCTagNumber;
    TCP_UDPPort1: TTCP_UDPPort;
    ToggleBox1: TToggleBox;
    procedure ConnectBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure IdleTimer1Timer(Sender: TObject);
//    procedure HMILabel2Click(Sender: TObject);
    procedure M1VoltsUpdate(Sender: TObject);

  private

  public
  var
    vf: Text;
    count: Integer;
    ii: Integer;
    DefaultLogInterval: String;
    TimerEnd,fopened: Boolean;
    ScheduleRun: Boolean;
    PLCBE: array[1..100] of TPLCBlockElement;
    NumberOfBatts, ConnectTimes: Integer;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }


procedure TForm1.IdleTimer1Timer(Sender: TObject);
begin
  TimerEnd := True;
end;

procedure TForm1.StopBtnClick(Sender: TObject);
begin
    TCP_UDPPort1.Active := False;
    TCP_UDPPort1.EnableAutoReconnect := False;
//    ShowMessage(DateTimeToStr(Now));
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
//  Form2.Enabled:=True;
  Form2.Show;
//  Form1.Close;FreeAndNil(Form1);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
     DateTimePicker1.DateTime:=IncSecond(NOW,10);
     DateTimePicker2.DateTime:=IncSecond(NOW,40);
end;


procedure TForm1.ConnectBtnClick(Sender: TObject);
var
  i: integer;
begin
     StopBtn.Click;                                            //stop the active connection
     Edit14.Text := DateTimeToStr(DateTimePicker1.DateTime);   //set the time

     IdleTimer1.Interval:=StrToInt(Edit13.Text)*1000;          //set default WriteToFile timer

     //Edit16.Enabled:=False;

     NumberOfBatts:=StrToInt(Edit16.Text);
     StringGrid1.RowCount:=NumberOfBatts+1; //RowCount value includes also the header row

     if ConnectTimes=1 then PLCBlock1.Size:=NumberOfBatts*5;      //Initial Run

     //if PLCBlock1.Size <= NumberOfBatts*5 then
          // If we need to read less data than before, then we read all the data based
          // on the previous value of block size but display only the required data.
          // This is a workaround since we can not delete an existed block element.
          // If we find a way to delete the array of PLC Block Elements then we could delete / free the whole array
          // and rebuild it based on the new NumberOfBatts (smaller than before).
          // One possible solution could be to loop on the previous big array and perform FreeAndNil(object).
          // FreeAndNil is better than just free since it ensures that object will be unassigned (while just onject.free does not unassign object

     if ConnectTimes > 1 then for i:=1 To PLCBlock1.Size do FreeAndNil(PLCBE[i]);
          //begin
                PLCBlock1.Size:=NumberOfBatts*5;       //Generex Holds 5 registers for each battery, starting from 1060
                count:=1;
                while count<=PLCBlock1.Size+1 do
                   begin
                     if not Assigned(PLCBE[count]) then PLCBE[count]:=TPLCBlockElement.Create(Form1);
                     //Assigned works fine to determine if an element exists and create it if it does not exist.
                     PLCBE[count].Index:=count-1;
                     PLCBE[count].PLCBlock:=PLCBlock1;
                     count:=count+1;
                   end;
          //end;
     TCP_UDPPort1.Host := Edit10.Text;                         //read the host
     TCP_UDPPort1.Port := StrToInt(Edit12.Text);               //read the port
     TCP_UDPPort1.Active := True;                              // Enable connection with above host/port
     TCP_UDPPort1.EnableAutoReconnect := True;
     Label12.Caption:=IntToStr(ConnectTimes);ConnectTimes:=ConnectTimes+1;
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
     ii := 1;
//     system.Assign(vf,'C:\Users\ge.vasiliou\Desktop\gt.csv');
     system.Assign(vf,'C:\gt.csv');
//     system.Rewrite(vf);
     DateTimePicker1.DateTime:=Now;
     DateTimePicker2.DateTime:=Now;
     ScheduleRun:=False;
     ConnectTimes:=1;

     //This is the magic code required to add dynamically components. You need to create the component on the form and get a valid  TagGUID
     {
     PLCBlockElement2:=TPLCBlockElement.Create(Form1);
     PLCBlockElement2.Index:=1;
     PLCBlockElement2.PLCBlock:=PLCBlock1;
     }

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
     if fopened then system.Close(vf);
end;


procedure TForm1.M1VoltsUpdate(Sender: TObject);
var
   b1,t1,b2,t2,b3,t3,d,writetofile: String;
   i,ind: Integer;

begin
//http://wiki.lazarus.freepascal.org/TStringGrid

     Label3.Caption := IntToStr(TCP_UDPPort1.RXBytes);
//     Edit11.Text:=FloatToStr(PLCBlockElement2.Value);
//     if not IdleTimer1.Enabled then
//     begin
          if Edit13.Text <> '' then IdleTimer1.Interval:=StrToInt(Edit13.Text)*1000;
          IdleTimer1.Enabled:=True;
//     end;
     //d := DateTimeToStr(Now);
     d := DateTimeToStr(PLCBlock1.ValueTimestamp);
     if (CompareDateTime(DateTimePicker1.DateTime,Now)<0) and (CompareDateTime(DateTimePicker2.DateTime,Now)>0) and (ToggleBox1.Checked)
     then
       begin
         Edit14.Text:='Scheduler Active';
         if not ScheduleRun then DefaultLogInterval:=Edit13.Text;
         Edit13.Text:=Edit15.Text;
         Edit13.Enabled:=False;
         ScheduleRun:=True;
       end
     else
       begin
          Edit14.Text:='Scheduler Not Active';
          Edit13.Enabled:=True;
          if ScheduleRun then Edit13.Text:=DefaultLogInterval;
          ScheduleRun:=False;
       end;
     Edit8.Text := d;
     Form2.Edit1.Text := Form2.HMILabel2.Caption;
//   Edit2.Text := M1Volts.GetNamePath;
     b1 := FloatToStr(M1Volts.Value/1000,FormatSettings);
     t1 := FloatToStr((M1Temp.Value-78)/2,FormatSettings);
     Edit2.Text := '1';Edit3.Text := b1;Edit4.Text := t1;

     b2 := FloatToStr(M2Volts.Value/1000,FormatSettings);
     t2 := FloatToStr((M2Temp.Value-78)/2,FormatSettings);

     b3 := FloatToStr(M3Volts.Value/1000,FormatSettings);
     t3 := FloatToStr((M3Temp.Value-78)/2,FormatSettings);

     Edit5.Text := '2';Edit6.Text := b2;Edit7.Text := t2;
//     for i:=1 to 18 do
//     begin
//       if (Components[i] is TPLCTagNumber) then writeln(i);
          StringGrid1.Cells[1,0]:='Temp';StringGrid1.Cells[2,0]:='Volts';
          {
          StringGrid1.Cells[0,1]:='No1';StringGrid1.Cells[0,2]:='No2';StringGrid1.Cells[0,3]:='No3';
          StringGrid1.Cells[1,1]:=b1;StringGrid1.Cells[2,1]:=t1;
          StringGrid1.Cells[1,2]:=b2;StringGrid1.Cells[2,2]:=t2;
          StringGrid1.Cells[1,3]:=b3;StringGrid1.Cells[2,3]:=t3;
          }
          i:=1;ind:=1;writetofile:=d;
          while i<=NumberOfBatts do
          begin
               StringGrid1.Cells[0,i]:=IntToStr(i);
               StringGrid1.Cells[1,i]:=FloatToStr((PLCBE[ind].Value-78)/2);StringGrid1.Cells[2,i]:=FloatToStr(PLCBE[ind+1].Value/1000);
          //We can use a string in order to concatenate all the values in one row like this:
               //Edit11.Text:=DateTimeToStr(PLCBlock1.ValueTimestamp);
               writetofile:=Concat(writetofile,';',FloatToStr(PLCBE[ind+1].Value/1000));
               //Edit11.Text:=writetofile;
               i:=i+1;ind:=ind+5;
          end;


     if TimerEnd then
          begin
               Edit9.Text := d;
               system.Append(vf);
               fopened := True;
//               writeln(vf, d, ';', b1, ';', b2,';',b3);
               writeln(vf, writetofile);
               TimerEnd := False;
          end;
//     end

end;

end.

