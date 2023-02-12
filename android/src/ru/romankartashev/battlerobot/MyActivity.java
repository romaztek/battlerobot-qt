package ru.romankartashev.battlerobot;

import org.qtproject.qt5.android.bindings.QtActivity;
import android.app.Activity;
import android.os.Bundle;
import android.bluetooth.*;
import android.content.Intent;

public class MyActivity extends QtActivity
{
    private final static int REQUEST_ENABLE_BT = 1;

    private static MyActivity m_instance;

    private BluetoothAdapter bluetoothAdapter;

    public MyActivity() {
        m_instance = this;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    public static void enableBluetooth() {
        m_instance.bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

        if (m_instance.bluetoothAdapter == null) {
            // Device does not support Bluetooth
        }
        else if (!m_instance.bluetoothAdapter.isEnabled()) {
            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            m_instance.startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
        }
    }

}
