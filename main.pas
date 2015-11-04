unit main;

{$mode objfpc}{$H+}

interface

uses
	Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
	StdCtrls, ExtCtrls, Buttons, Process;

type
	Tfrm_logout = class(TForm)
						btnOk: TButton;
						btnCancel: TButton;
						ActionsGroup: TRadioGroup;
						cbSession: TComboBox;

	procedure FormCreate(Sender: TObject);
	procedure OnClickButton(Sender: TObject);
	procedure OnActionsClick(Sender: TObject);
	procedure SaveConfig;
	procedure LoadConfig;
	procedure ExecuteCommand;
	end;

var
	frm_logout: Tfrm_logout;

implementation

{$R *.lfm}


procedure Tfrm_logout.FormCreate(Sender: TObject);
begin
	LoadConfig;
end;

procedure Tfrm_logout.LoadConfig;
var
   loadFile : TextFile;
   data : string;
   index : integer;
begin
	AssignFile (loadFile,GetAppConfigFile(false));
	try
		reset (loadFile);
		read (loadFile, data);
		CloseFile (loadFile);
	  except
     on e : exception do
     begin
        writeln ('Error al leer el archivo de configuración: ' + e.Message);
	 end;
	end;

	index := cbSession.Items.IndexOf (data);

	if index <> -1 then
	begin
		 cbSession.ItemIndex := index;
	end;
end;

procedure Tfrm_logout.SaveConfig;
var
	saveFile : TextFile;
begin
	AssignFile (saveFile,GetAppConfigFile(false));
	try
		rewrite (saveFile);
		writeln (saveFile, cbSession.Items[cbSession.ItemIndex]);
		CloseFile (saveFile);
		except
      on e : exception do
      begin
         write ('Error al escribir el archivo de configuración: ' + e.Message);
		end;
	end;
end;

procedure Tfrm_logout.OnClickButton(Sender: TObject);
begin
	if Sender = btnCancel then
	begin
		Close;
	end
	else {btnOk}
	begin
		SaveConfig;
		ExecuteCommand;
		Close;
	end;
end;

procedure Tfrm_logout.OnActionsClick(Sender: TObject);
begin
       cbSession.Enabled := false;
       // Supone que Sesion estará último siempre.
       if ActionsGroup.ItemIndex = ActionsGroup.Items.Count - 1 then
              cbSession.Enabled := true;
end;

procedure Tfrm_logout.ExecuteCommand;
const
     SYSTEMCTL = 'systemctl';
var
     output : ansistring;
begin
     case ActionsGroup.Items[ActionsGroup.ItemIndex] of
		'Apagar' : RunCommand (SYSTEMCTL,['poweroff'], output);
	  	'Suspender' : RunCommand (SYSTEMCTL, ['suspend'], output);
	  	'Reiniciar' : RunCommand (SYSTEMCTL, ['reboot'], output);
	  	'Hibernar'  : RunCommand (SYSTEMCTL, ['hibernate'], output);
	  	else // Sesion
			case cbSession.Items[cbSession.Itemindex] of
				 // main.lfm
				'Fluxbox' : RunCommand ('fluxbox-remote', ['"Exit"'], output);
				'i3'      : RunCommand ('i3-msg', ['exit'], output);
				'JWM'     : RunCommand ('jwm', ['-exit'], output);
				'Openbox' : RunCommand ('openbox', ['--exit'], output);
				'PekWM'   : RunCommand ('killall', ['-9', 'peakwm'], output);
			end;
	  end;
end;

end.

