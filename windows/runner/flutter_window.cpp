#include "flutter_window.h"

#include <optional>
#include <codecvt>
#include <locale>

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include "flutter/generated_plugin_registrant.h"

#define WM_TRAYICON         (WM_USER + 1)
#define IDM_TRAY_SHOW       3001
#define IDM_TRAY_EXIT       3002
#define IDM_TRAY_CONNECT    3003
#define IDM_TRAY_DISCONNECT 3004

static std::wstring Utf8ToWide(const std::string& s) {
  if (s.empty()) return L"";
  int len = MultiByteToWideChar(CP_UTF8, 0, s.c_str(), -1, nullptr, 0);
  std::wstring w(len - 1, 0);
  MultiByteToWideChar(CP_UTF8, 0, s.c_str(), -1, &w[0], len);
  return w;
}

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  // Method channel for tray icon actions (connect / disconnect / hide).
  tray_channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(),
      "com.app.vpn/tray",
      &flutter::StandardMethodCodec::GetInstance());

  tray_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        HWND hwnd = GetHandle();
        if (call.method_name() == "hide") {
          ShowWindow(hwnd, SW_HIDE);
          result->Success();
        } else if (call.method_name() == "minimize") {
          ShowWindow(hwnd, SW_MINIMIZE);
          result->Success();
        } else if (call.method_name() == "close") {
          DestroyWindow(hwnd);
          result->Success();
        } else if (call.method_name() == "startDrag") {
          ReleaseCapture();
          SendMessage(hwnd, WM_NCLBUTTONDOWN, HTCAPTION, 0);
          result->Success();
        } else if (call.method_name() == "updateStatus") {
          const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
          if (args) {
            auto get = [&](const char* key) -> std::string {
              auto it = args->find(flutter::EncodableValue(std::string(key)));
              if (it != args->end()) {
                const auto* v = std::get_if<std::string>(&it->second);
                if (v) return *v;
              }
              return "";
            };
            auto getBool = [&](const char* key) -> bool {
              auto it = args->find(flutter::EncodableValue(std::string(key)));
              if (it != args->end()) {
                const auto* v = std::get_if<bool>(&it->second);
                if (v) return *v;
              }
              return false;
            };
            vpn_connected_ = getBool("connected");
            vpn_server_ = Utf8ToWide(get("server"));
            vpn_download_ = Utf8ToWide(get("download"));
            vpn_upload_ = Utf8ToWide(get("upload"));
          }
          result->Success();
        } else {
          result->NotImplemented();
        }
      });

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;

    case WM_TRAYICON:
      if (lparam == WM_LBUTTONUP || lparam == WM_LBUTTONDBLCLK) {
        ShowWindow(hwnd, SW_SHOW);
        SetForegroundWindow(hwnd);
        return 0;
      }
      if (lparam == WM_RBUTTONUP) {
        POINT pt;
        GetCursorPos(&pt);
        HMENU menu = CreatePopupMenu();

        // Status info (non-clickable, grayed out).
        if (vpn_connected_) {
          std::wstring status = L"Connected: " + vpn_server_;
          AppendMenu(menu, MF_STRING | MF_GRAYED, 0, status.c_str());
          std::wstring dl = L"\x2193 " + vpn_download_;
          std::wstring ul = L"\x2191 " + vpn_upload_;
          AppendMenu(menu, MF_STRING | MF_GRAYED, 0, dl.c_str());
          AppendMenu(menu, MF_STRING | MF_GRAYED, 0, ul.c_str());
        } else {
          AppendMenu(menu, MF_STRING | MF_GRAYED, 0, L"Disconnected");
        }
        AppendMenu(menu, MF_SEPARATOR, 0, nullptr);

        AppendMenu(menu, MF_STRING, IDM_TRAY_SHOW, L"Show");
        if (vpn_connected_) {
          AppendMenu(menu, MF_STRING, IDM_TRAY_DISCONNECT, L"Disconnect");
        } else {
          AppendMenu(menu, MF_STRING, IDM_TRAY_CONNECT, L"Connect");
        }
        AppendMenu(menu, MF_SEPARATOR, 0, nullptr);
        AppendMenu(menu, MF_STRING, IDM_TRAY_EXIT, L"Exit");

        SetForegroundWindow(hwnd);
        TrackPopupMenu(menu, TPM_BOTTOMALIGN | TPM_LEFTALIGN, pt.x, pt.y, 0, hwnd, nullptr);
        DestroyMenu(menu);
        return 0;
      }
      return 0;

    case WM_COMMAND:
      if (LOWORD(wparam) == IDM_TRAY_SHOW) {
        ShowWindow(hwnd, SW_SHOW);
        SetForegroundWindow(hwnd);
      } else if (LOWORD(wparam) == IDM_TRAY_EXIT) {
        RemoveTrayIcon();
        DestroyWindow(hwnd);
      } else if (tray_channel_) {
        if (LOWORD(wparam) == IDM_TRAY_CONNECT) {
          tray_channel_->InvokeMethod("connect", nullptr);
        } else if (LOWORD(wparam) == IDM_TRAY_DISCONNECT) {
          tray_channel_->InvokeMethod("disconnect", nullptr);
        }
      }
      return 0;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
