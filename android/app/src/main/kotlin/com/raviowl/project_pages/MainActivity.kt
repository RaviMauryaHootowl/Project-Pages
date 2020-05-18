package com.raviowl.project_pages

import android.Manifest
import android.os.Environment
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.raviowl.project_pages/pages"
    var files = ArrayList<ArrayList<String>>();

    fun Search_Dir(dir: File) {
        val pdfPattern = ".pdf"
        val FileList: Array<File> = dir.listFiles()
        if (FileList != null) {
            for (i in FileList.indices) {
                if (FileList[i].isDirectory()) {
                    Search_Dir(FileList[i])
                } else {
                    if (FileList[i].getName().endsWith(pdfPattern)) {
                        //here you have that file.
                        var temps = ArrayList<String>();
                        temps.add(FileList[i].name);
                        temps.add(FileList[i].path);
                        files.add(temps);
                    }
                }
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            // Note: this method is invoked on the main thread.
            // TODO
            if(call.method=="getPermission"){
                ActivityCompat.requestPermissions(activity,
                        arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE),
                        0);
                result.success("success");
            }else if(call.method=="getFiles"){
                files.clear();
                ActivityCompat.requestPermissions(activity,
                        arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE),
                        0);
                Search_Dir(Environment.getExternalStorageDirectory());
                //result.success(Environment.getExternalStorageDirectory().path);
                result.success(files);
            }
        }

    }
}
