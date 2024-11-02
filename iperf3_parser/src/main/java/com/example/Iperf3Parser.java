package com.example;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;

public class Iperf3Parser {
    public static void main(String[] args) {

        String filePath = "/mnt/k3d/egress_gateway/iperf_client_json_cilium_egress_gateway.json";
        ObjectMapper objectMapper = new ObjectMapper();
        try {
            File file = new File(filePath);
            JsonNode jsonNode = objectMapper.readTree(file);

            System.out.println(jsonNode.toPrettyString());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
