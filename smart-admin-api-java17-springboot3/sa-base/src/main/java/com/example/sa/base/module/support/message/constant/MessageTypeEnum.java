package com.example.sa.base.module.support.message.constant;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.example.sa.base.common.enumeration.BaseEnum;


@Getter
@AllArgsConstructor
public enum MessageTypeEnum implements BaseEnum {

    MAIL(1, "站内信"),

    ORDER(2, "订单"),
    ;

    private final Integer value;

    private final String desc;
}
