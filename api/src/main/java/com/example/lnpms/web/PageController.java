package com.example.lnpms.web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 页面控制器：返回HTML页面
 */
@Controller
public class PageController {
    
    @GetMapping("/")
    public String home() {
        return "index";
    }
}

