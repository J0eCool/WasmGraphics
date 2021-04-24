(module
  (import "consts" "imageStart" (global $imageStart i32))
  (import "consts" "canvasWidth" (global $canvasWidth i32))
  (import "consts" "canvasHeight" (global $canvasHeight i32))

  (memory (export "memory") 256)
  (global $pos (mut i32) (i32.const 0))
  (global $t (mut i32) (i32.const 0))
  (global $clearColor i32 (i32.const 0xff808080))

  (func $toX (param $pos i32) (result i32)
    ;; image index -> x
    (i32.rem_u
      (global.get $pos)
      (global.get $canvasWidth)
    )
  )
  (func $toY (param $pos i32) (result i32)
    ;; image index -> y
    (i32.div_u
      (global.get $pos)
      (global.get $canvasWidth)
    )
  )
  (func $toPos (param $x i32) (param $y i32) (result i32)
    ;; (x, y) -> image index
    (i32.add
      (local.get $x)
      (i32.mul
        (local.get $y)
        (global.get $canvasWidth)
      )
    )
  )

  (func $setPixel (param $x i32) (param $y i32) (param $color i32)
    (if (i32.lt_s (local.get $x) (i32.const 0)) (return))
    (if (i32.ge_s (local.get $x) (global.get $canvasWidth)) (return))
    ;; Y bounds checks can be deferred to setPixelPos, because that would be
    ;; outside the memory slice
    (call $setPixelPos
      (call $toPos
        (local.get $x)
        (local.get $y)
      )
      (local.get $color)
    )
  )
  (func $setPixelPos (param $pos i32) (param $color i32)
    (if (i32.lt_s (local.get $pos) (i32.const 0)) (return))
    (if (i32.ge_s (local.get $pos) (call $numPixels)) (return))
    (i32.store
      (i32.add
        (global.get $imageStart)
        (i32.mul
          (local.get $pos)
          (i32.const 4)
        )
      )
      (local.get $color)
    )
  )
  (func $rgb (param $r i32) (param $g i32) (param $b i32) (result i32)
    local.get $r

    local.get $g
    i32.const 8
    i32.shl

    local.get $b
    i32.const 16
    i32.shl

    ;; alpha
    i32.const 0xff
    i32.const 24
    i32.shl

    i32.or
    i32.or
    i32.or
  )
  (func $clearScreen
    (local $i i32)
    (loop
      (call $setPixelPos
        (local.get $i)
        (global.get $clearColor)
      )
      (br_if 0
        (i32.le_u
          (local.tee $i
            (i32.add
              (local.get $i)
              (i32.const 1)
            )
          )
          (call $numPixels)
        )
      )
    )
  )

  (func $numPixels (result i32)
    (i32.mul
      (global.get $canvasWidth)
      (global.get $canvasHeight)
    )
  )
  (func $update (export "update")
    (local i32 i32 i32 i32)
    i32.const 0
    local.set 0

    call $numPixels
    local.set 3

    loop
      global.get $imageStart
      local.get 0
      i32.const 4
      i32.mul
      i32.add
      local.tee 1
      i32.load

      local.get 0
      i32.add
      i32.const 0xff000000
      i32.or
      local.set 2
      local.get 1
      local.get 2
      i32.store

      local.get 0
      i32.const 1
      i32.add
      local.tee 0
      local.get 3
      i32.lt_u
      br_if 0
    end
  )
)
