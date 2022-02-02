package org.apache.zeppelin.flink.udf;

import org.apache.flink.table.functions.ScalarFunction;
import org.json.*;

public class JSONExtract extends ScalarFunction {
  public String eval(String key, String json) {
    JSONObject obj = new JSONObject(json);
    return obj.getString(key).toString();
  }
}