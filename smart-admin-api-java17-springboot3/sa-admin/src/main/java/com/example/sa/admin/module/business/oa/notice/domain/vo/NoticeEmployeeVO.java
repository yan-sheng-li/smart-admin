package com.example.sa.admin.module.business.oa.notice.domain.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDate;

@Data
public class NoticeEmployeeVO extends NoticeVO {

    @Schema(description = "是否查看")
    private Boolean viewFlag;

    @Schema(description = "发布日期")
    private LocalDate publishDate;

}
