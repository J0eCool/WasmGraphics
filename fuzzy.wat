(module
  (import "consts" "imageStart" (global $imageStart i32))
  (import "consts" "canvasWidth" (global $canvasWidth i32))
  (import "consts" "canvasHeight" (global $canvasHeight i32))

  (memory (export "memory") 256)

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
