<template>
  <a-modal :open="visible" width="600px" title="联系客服人员" :closable="false" :maskClosable="true">
    <div style="text-align:center; padding: 40px 0; color: rgba(0,0,0,0.65)">
      如需帮助，请联系系统管理员。
    </div>
    <template #footer>
      <a-button type="primary" @click="hide">知道了</a-button>
    </template>
  </a-modal>
</template>
<script setup>
  import { ref } from 'vue';
  defineExpose({
    show,
  });

  const visible = ref(false);
  function show() {
    visible.value = true;
  }
  function hide() {
    visible.value = false;
  }
</script>
<style lang="less" scoped>
  .app-qr-box {
    display: flex;
    height: 170px;
    align-items: center;
    justify-content: space-around;
    .app-qr {
      display: flex;
      align-items: center;
      width: 33%;
      justify-content: center;
      flex-direction: column;
      > img {
        width: 100%;
        max-width: 150px;
        height: 100%;
        max-height: 150px;
      }
      .strong {
        font-weight: 600;
      }
      .qr-desc {
        display: flex;
        align-items: center;
        font-size: 12px;
        text-align: center;
        overflow-x: hidden;
        > img {
          width: 15px;
          height: 18px;
          margin-right: 9px;
        }
      }
    }
  }

  .ant-carousel :deep(.slick-slide) {
    text-align: center;
    height: 120px;
    line-height: 120px;
    width: 120px;
    background: #364d79;
    overflow: hidden;
  }

  .ant-carousel :deep(.slick-slide h3) {
    color: #fff;
  }
</style>
