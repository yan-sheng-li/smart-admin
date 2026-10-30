package com.example.sa.base.module.support.message.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import com.example.sa.base.module.support.message.constant.MessageTypeEnum;

import java.time.LocalDateTime;

@Data
@TableName("t_message")
public class MessageEntity {

    @TableId(type = IdType.AUTO)
    private Long messageId;

    /**
     * 消息类型
     *
     * @see MessageTypeEnum
     */
    private Integer messageType;
    /**
     * 接收者类型
     *
     * @see com.example.sa.base.common.enumeration.UserTypeEnum
     */
    private Integer receiverUserType;

    /**
     * 接收者id
     */
    private Long receiverUserId;

    /**
     * 相关业务id
     */
    private String dataId;

    /**
     * 消息标题
     */
    private String title;

    /**
     * 消息内容
     */
    private String content;

    /**
     * 是否已读
     */
    private Boolean readFlag;

    /**
     * 已读时间
     */
    private LocalDateTime readTime;

    private LocalDateTime updateTime;

    private LocalDateTime createTime;
}
